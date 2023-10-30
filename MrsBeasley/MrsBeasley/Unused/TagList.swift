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
        //        predicate: nil,
        animation: .default)
    private var tags: FetchedResults<Tag>
    @State private var selectedTag: Tag?
    @State private var searchText: String = ""
    @State var showAddTag = false
    @State var nt: String = ""
    
    var body: some View {
        ZStack {
            VStack {
                Text("Edit Tag")
                HStack {
                    VStack(alignment: .leading) {
                        
                        Divider()
                        if tags.isEmpty {
                            Text("no tags")
                        } else {
                            List(selection: $selectedTag) {
                                ForEach(tags,  id: \.self) { tag in
                                    Text(tag.title ?? "noname").font(.title2)
                                }
                                .onDelete(perform: deleteTags)
                            }
                        }
                        Spacer()
                        Button("Edit \(Image(systemName: "tag"))") {
                            nt = ""
                            showAddTag.toggle()
                        }
                        .controlSize(.small)
                        .buttonStyle(.borderedProminent)
                    }
                    if (showAddTag && selectedTag != nil) {
                        VStack(alignment: .leading) {
                            Text("Edit Tag")
                                .font(.headline)
                            Divider()
                            EditTagView(ptag: selectedTag!)
                                .onSubmit {
                                    addTag(nt)
                                    showAddTag.toggle()
                                }
                        }
                        .padding(30)

                }
            }
        }
        }
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
