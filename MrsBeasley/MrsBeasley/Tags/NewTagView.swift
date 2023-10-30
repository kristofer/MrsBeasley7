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
            VStack {
                Picker("Tag Kind", selection: $newKind) {
                    ForEach(TagKinds.allCases, id: \.self) { option in
                        Text(String(describing: option))
                    }
                }
                .pickerStyle(.segmented)

                Text("Value: \(newKind)")
            }

            Button("Save") {
                newTag()
            }
        }
    }
    
    func newTag() {
        let _ = Tag.createIfNoExist(context: moc, title: newName)
        moc.flushChanges()
        newKind = 0
        newName = ""
    }
}

