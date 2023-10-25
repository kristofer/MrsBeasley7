//
//  NoteSubList.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/25/23.
//

import SwiftUI

struct NoteSubList: View {
    @ObservedObject var tag: Tag
    @Binding var noteId: Note?
    var tagNotes: [Note] {
        if let items = tag.notes as? Set<Note> {
            print("tagcount \(String(describing: tag.title)) \(String(describing: tag.notes?.count))")
            return Array(items)
        }
        return [Note]()
    }

    var body: some View {
        ForEach(tagNotes, id: \.self ) { aNote in
                NoteRow(note: aNote)
        }
            //.onDelete(perform: deleteNotes)
    }
}

#Preview {
    EmptyView()
}
