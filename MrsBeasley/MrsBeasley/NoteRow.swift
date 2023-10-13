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
        VStack(alignment: .leading) {
            if let title = note.title {
                Text(title)
            } else {
                Text("untitled")
            }
            Text(note.uuid?.uuidString ?? "??")
                .font(.caption2)
                .foregroundColor(.gray)
        }
    }
}

struct NoteRow_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
