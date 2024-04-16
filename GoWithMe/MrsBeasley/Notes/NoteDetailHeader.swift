//
//  NoteDetailHeader.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import SwiftUI

// this view seems to make the updating on the title field to work
// correctly on changing of the selection
struct NoteTitleEditView: View {
    @ObservedObject var note: Note
    var body: some View {
        TextField("Title", text: $note.title.toUnwrapped(defaultValue: ""))
    }
}

struct NoteDetailHeader: View {
    @ObservedObject var note: Note

    var body: some View {
        VStack() {
            HStack {
                NoteTitleEditView(note: note)
                Spacer()
                ShowTagView(note: note)
                if UIDevice.current.localizedModel == "iPad" {
                    Text(note.mimetype ?? "text/plain")
                        .font(.caption).italic()
                    if note.timestamp != nil {
                        VStack {
                            Text("Saved at \(note.lastmodified ?? .distantPast, formatter: noteDateFormatter)")
                                .font(.caption).italic()
                            Text("Created at \(note.timestamp ?? .distantPast, formatter: noteDateFormatter)")
                                .font(.caption).italic()
                        }
                    }
                }
            }
            .padding(5)
        }
    }
}
