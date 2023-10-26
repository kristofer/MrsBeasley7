//
//  NewURLView.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/22/23.
//

import SwiftUI

struct NewURLView: View {
    @Environment(\.managedObjectContext) var moc

    @State var newURL = ""
    @State var newName = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Label("NewURL", systemImage: "link.icloud")
                TextField("", text: $newURL)
            }
            HStack {
                Label("NewName", systemImage: "t.square")
                TextField("", text: $newName)
            }
            Button("Save") {
                newWebNote()
            }
        }
    }
    
    func newWebNote() {
        let nn = Note(context: moc, title: newName)
        nn.body = newURL
        nn.mimetype = "text/html"
        moc.flushChanges()
        newURL = ""
        newName = ""
    }
}
