//
//  NoteDetailHeader.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import SwiftUI

struct NoteDetailHeader: View {
    @ObservedObject var note: Note

    var body: some View {
        TextField("title", text: $note.title.toUnwrapped(defaultValue: ""))
            .font(.title)
        ShowTagView(note: note)
        Text(note.mimetype ?? "text/plain")
            .font(.caption).italic()
        if let ts = note.timestamp {
            Text("Created at \(note.timestamp!, formatter: noteDateFormatter)")
                .font(.caption).italic()
        }
    }
}

struct NoteDetailHeader_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
