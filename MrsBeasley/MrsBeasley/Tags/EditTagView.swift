//
//  EditTagView.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/31/23.
//

import SwiftUI

struct EditTagView: View {
    @Environment(\.managedObjectContext) var moc
    
    private var tag: Tag?
    
    @State var newKind = TagKinds.plain
    @State var newName: String
    
    init(ptag: Tag?) {
        if let   ttag = ptag {
            tag = ttag
            newKind = TagKinds(rawValue: Int(ttag.kind ?? 0))!
            newName = ttag.title ?? "??"
            return
        }
        tag = nil
        newKind = TagKinds(rawValue: 0)!
        newName = ""
    }
    
    var body: some View {
        HStack(alignment: .top) {
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
                Button("Save") {
                    newTag()
                }
            }
        }
        .padding()
    }
    
    func newTag() {
        let t = Tag.createIfNoExist(context: moc, title: newName)
        t.title = newName
        t.kind = Int32(newKind.rawValue)
        moc.flushChanges()
    }
}

