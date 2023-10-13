//
//  NoteRow.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import SwiftUI

struct NoteRow: View {
    var note: Note
    
    var body: some View {
        HStack {
            Text("Note at \(note.timestamp!, formatter: noteDateFormatter)")
            Spacer()
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
