//
//  TagList.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/15/23.
//

import SwiftUI
import CoreData

struct TagList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.title, ascending: true)],
        animation: .default)
    private var tags: FetchedResults<Tag>
    @State private var selectedTag: Tag?
    
    var body: some View {
        NavigationView {
                List(tags,  id: \.self) { tag in
                    NavigationLink(destination: EditTagView(ptag: tag))
                     {
                        Text(tag.title ?? "??")
                    }
                }
        }
        .navigationTitle("Select a tag")


    }
    
    
    //------
    private func deleteTags(offsets: IndexSet) {
        withAnimation {
            offsets.map { tags[$0] }.forEach(viewContext.delete)
            viewContext.flushChanges()
        }
    }
    private func addTag(_ t: String) {
        let _ = Tag.createIfNoExist(context: viewContext, title: t)
        viewContext.flushChanges()
    }
}

struct TagList_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
