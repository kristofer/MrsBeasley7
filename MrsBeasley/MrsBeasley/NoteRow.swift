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
            if let actualTitle = note.title, actualTitle != "" {
                Text(actualTitle)
            }else {
                Text("*no title*")
            }
            Text("\(note.timestamp!, formatter: noteDateFormatter)")
            //Text(note.uuid?.uuidString ?? "??")
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
