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
        VStack() {
            HStack {
                TextField("", text: $note.title.toUnwrapped(defaultValue: ""))
                Spacer()
                ShowTagView(note: note)
                if UIDevice.current.localizedModel == "iPad" {
                    Text(note.mimetype ?? "text/plain")
                        .font(.caption).italic()
                    if note.timestamp != nil {
                        VStack {
                            Text("Saved at \(note.lastmodified ?? .distantPast, formatter: noteDateFormatter)")
                                .font(.caption).italic()
                            Text("Created at \(note.timestamp!, formatter: noteDateFormatter)")
                                .font(.caption).italic()
                        }
                    }
                }
            }
            .padding(5)
        }
    }
}
