//
//  NoteRow.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct NoteRow: View {
    @ObservedObject var note: Note

    var body: some View {
        HStack {
            Image(systemName: note.iconForMimetype())
                    .resizable()
                    .frame(width: 25, height: 25)
            VStack(alignment: .leading) {
                if let actualTitle = note.title, actualTitle != "" {
                    Text(actualTitle)
                }else {
                    Text("*no title*")
                }
                if let ts = note.timestamp {
                    Text("\(ts, formatter: noteDateFormatter)")
                        .font(.caption2)
                }
            }
        }
    }
}

struct NoteRow_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
