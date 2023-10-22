//
//  NoteMainView.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/22/23.
//

import SwiftUI

struct NoteMainView: View {
    @ObservedObject var note: Note

    var body: some View {
        VStack {
            NoteDetailHeader(note: note)
            NoteTextEditor(note: note)
        }
    }
}

#Preview {
    EmptyView()
}
