//
//  NewTagView.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/25/23.
//

import SwiftUI

struct NewTagView: View {
    @Environment(\.managedObjectContext) var moc

    @State var newKind = 0
    @State var newName = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Label("New Tag:", systemImage: "tag")
                TextField("", text: $newName)
                    .border(.gray)
            }
            HStack {
                Label("Tag Kind", systemImage: "t.square")
                TextField("", value: $newKind, format: .number)
            }
            Button("Save") {
                newTag()
            }
        }
    }
    
    func newTag() {
        let nn = Tag(context: moc, title: newName)
        nn.kind = 0
        moc.flushChanges()
        newKind = 0
        newName = ""
    }
}

