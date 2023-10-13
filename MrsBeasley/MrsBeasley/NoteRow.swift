//
//  NoteRow.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import SwiftUI

struct NoteRow: View {
    @ObservedObject var note: Note

    var body: some View {
        HStack {
            if let title = note.title {
                Text(title)
            } else {
                Text("untitled")
            }
        }
    }
}

struct NoteRow_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
