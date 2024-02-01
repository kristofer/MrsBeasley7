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
    private var fontsize: CGFloat {
        if UIDevice.current.localizedModel == "iPhone" {
            return 16.0
        } else if UIDevice.runningOnMac {
            return 22.0
        } else if UIDevice.current.localizedModel == "iPad" {
            return 18.0
        }
        return 18.0
    }

    var body: some View {
        HStack {
            Image(systemName: note.iconForMimetype())
                .imageScale(.medium)
            VStack(alignment: .leading) {
                if let actualTitle = note.title, actualTitle != "" {
                    Text(actualTitle)
                        .font(.custom("Inconsolata", size: fontsize)).bold()
                }else {
                    Text("*no title*")
                }
                if let ts = note.timestamp {
                    Text("\(ts, formatter: noteDateFormatter)")
                        .font(.custom("Inconsolata", size: fontsize - 6.0))
                }
            }
        }
        .padding(4)
    }
}

struct NoteRow_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
