//
//  NoteDetail.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import SwiftUI

struct NoteDetail: View {
    var note: Note
    
    var body: some View {
        VStack {
            NoteDetailHeader(note: note)
            Divider()
            NoteBody(content: $note.body)
        }
    }
}

struct NoteDetail_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
