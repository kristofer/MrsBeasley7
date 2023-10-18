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
    
//    @ObservedObject var note: Note
    
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
            VStack(alignment: .leading) {
                Text("Categories")
                    .font(.headline)
                Divider()
                if tags.isEmpty {
                    Text("no categories")
                } else {
                    List(selection: $selectedTag) {
                        ForEach(tags,  id: \.self) { tag in
                            Text(tag.title ?? "noname").font(.title2)
                        }
                        .onDelete(perform: deleteTags)
                    }
                }
                Spacer()
                Button("+ \(Image(systemName: "tag"))") {
                    nt = ""
                    showAddTag.toggle()
                }
                .buttonStyle(.borderedProminent)
            }
        }
        if (showAddTag) {
            VStack(alignment: .leading) {
                Text("Add Category")
                    .font(.headline)
                Divider()
                TextField("new category?", text: $nt)
                    .font(.title2)
                    .autocorrectionDisabled(true)
                    .autocapitalization(.none)
                    .onSubmit {
                        addTag(nt)
                        showAddTag.toggle()
                    }
            }
            .padding(30)
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
        let _ = Tag(context: viewContext, title: t)
        viewContext.flushChanges()
    }
}

extension Tag {
    convenience init(
      context moc: NSManagedObjectContext,
      title: String
    ) {
        self.init(context: moc)
        self.uuid = UUID()
        self.title = title
    }
    
}

struct TagList_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
