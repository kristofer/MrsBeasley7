//
//  NewTagView.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/25/23.
//

import SwiftUI

struct NewTagView: View {
    @Environment(\.managedObjectContext) var moc
    
    @State var newKind = TagKinds.plain
    @State var newName = ""
    
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Label("Name:", systemImage: "tag")
                TextField("", text: $newName)
                    .border(.gray)
            }
            VStack {
                Picker("Tag Kind", selection: $newKind) {
                    ForEach(TagKinds.allCases, id: \.self) { option in
                        Text(String(describing: option))
                    }
                }
                .pickerStyle(.segmented)
            }
            Button("Save") {
                newTag()
            }
        }
    }
    
    func newTag() {
        let t = Tag.createIfNoExist(context: moc, title: newName)
        t.kind = Int32(newKind.rawValue)
        moc.flushChanges()
        newKind = TagKinds.plain
        newName = ""
    }
}
