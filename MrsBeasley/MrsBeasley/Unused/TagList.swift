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
    @State var newKind = TagKinds.plain
    @State var newName: String = ""
    
    var body: some View {
//        Text("Existing Tags")
//            .font(.body)
        HStack {
            List(selection: $selectedTag) {
                ForEach(tags,  id: \.self) { tag in
                    Text(tag.title ?? "??")
                        .font(.subheadline)
                }
                .onDelete(perform: deleteTags)
            }
            .listStyle(PlainListStyle())
            .onChange(of: $selectedTag.wrappedValue, perform: { _ in
                fillView()
            })
            VStack(alignment: .leading) {
                
                HStack{
                    Label("Name:", systemImage: "tag")
                    TextField("", text: $newName)
                        .border(.gray)
                }
                
                Picker("Tag Kind", selection: $newKind) {
                    ForEach(TagKinds.allCases, id: \.self) { option in
                        Text(String(describing: option))
                    }
                }
                .pickerStyle(.segmented)
                HStack {
                    Spacer()
                    Button("Save") {
                        saveTag()
                    }
                }
            }
            
        }
    }
    
    
    //------
    private func fillView() {
        if let tag = selectedTag {
            newName = tag.title!
            newKind = TagKinds(rawValue: Int(tag.kind))!
        }
    }
    func saveTag() {
        //let t = Tag.createIfNoExist(context: viewContext, title: selectedTag?.title! ?? "untitled")
        if let tag = selectedTag {
            tag.title = newName
            tag.kind = Int32(newKind.rawValue)
            viewContext.flushChanges()
            selectedTag = nil
        }
    }
    
    private func deleteTags(offsets: IndexSet) {
        withAnimation {
            offsets.map { tags[$0] }.forEach(viewContext.delete)
            viewContext.flushChanges()
        }
        newName = ""
        newKind = TagKinds(rawValue: 0)!
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
