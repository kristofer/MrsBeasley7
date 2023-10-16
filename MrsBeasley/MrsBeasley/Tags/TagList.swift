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
    
    @ObservedObject var note: Note
    
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
                Text("Categories")
                    .font(.headline)
                Divider()
                if tags.isEmpty {
                    Text("no categories")
                } else {
                    List(selection: $selectedTag) {
                        ForEach(tags,  id: \.self) { tag in
                            Text(tag.title ?? "noname")
                        }
                        .onDelete(perform: deleteTags)
                    }
                }
                Spacer()
                Button("+ \(Image(systemName: "tag"))") {
                    showAddTag.toggle()
                }
            }
        }
        .sheet(isPresented: $showAddTag) {
            VStack(alignment: .leading) {
                Text("new catgory")
                    .presentationDetents([.medium, .large])
                TextField("Category:", text: $nt)
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

//struct TagPickerView : View {
//    @Environment(\.managedObjectContext) private var viewContext
//    @ObservedObject var note: Note
//    @Binding var showModal: Bool
//    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.title, ascending: true)],
//        animation: .default)
//    private var tags: FetchedResults<Tag>
//    
//    func save() {
//        try! viewContext.save()
//        showModal = false
//    }
//    
//    var body: some View {
//        VStack {
//            Button(action: {showModal = false}) {
//                Text("Close")
//            }
//            Picker(selection: $note.tags, label: Text("Categories")) {
//                ForEach(tags, id: \.self) { tag in
//                    Text("\(tag.title!)")
//                        .tag(note as Note?)
//                }
//            }
//            //Text("Selected: \(.title!)")
//            Button(action: {save()}) {
//                Text("Save")
//            }
//        }
//        
//    }
//}
