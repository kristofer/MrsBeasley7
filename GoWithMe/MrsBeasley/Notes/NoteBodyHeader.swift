//
//  NoteBodyHeader.swift
//  GoWithMe
//
//  Created by Kr Younger on 1/27/25.
//

import SwiftUI

// this view seems to make the updating on the title field to work
// correctly on changing of the selection
struct NoteBodyEditView: View {
    @ObservedObject var note: Note
    var body: some View {
        TextField("N.B.", text: $note.comments.toUnwrapped(defaultValue: ""))
    }
}

struct NoteBodyHeader: View {
    @ObservedObject var note: Note

    var body: some View {
        VStack() {
                NoteBodyEditView(note: note)
//                Spacer()
                if UIDevice.current.localizedModel == "iPad" {
                }
        }
    }
}
