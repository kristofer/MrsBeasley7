//
//  NoteMainView.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/22/23.
//

import SwiftUI
import UniformTypeIdentifiers

struct NoteMainView: View {
    @ObservedObject var note: Note
    
    var body: some View {
        // Check if note is still valid (not deleted)
        if !note.isDeleted && !note.isFault {
            VStack(alignment: .leading) {
                if let mt = note.mimetype {
                    switch mt {
                    case UTType.plainText.preferredMIMEType : //"text/plain"
                        NoteTextEditor(note: note)
                    case UTType.html.preferredMIMEType : //"text/html" :
                        // Safely unwrap note.body to prevent crash when note is deleted
                        if let noteBody = note.body, 
                           let thisUrl = URL(string: noteBody) {
                            HTMLNoteView(note: note, thisUrl: thisUrl)
                        } else {
                            Text("Unable to load URL")
                                .foregroundColor(.red)
                        }
                    case UTType.pdf.preferredMIMEType :
                        if let thisUrl = note.loadBlobToData() {
                            PDFNoteView(note: note, thisUrl: thisUrl)
                        } else {
                            Text("Unable to load PDF")
                                .foregroundColor(.red)
                        }
                    default:
                        Text("mimetype is not text, html or PDF")
                            .foregroundColor(.red)
                        NoteDetailHeader(note: note)
                        FileAssetView(n: note)
                            
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        } else {
            // Note has been deleted, show placeholder
            ContentUnavailableView(
                "Note Deleted",
                systemImage: "trash",
                description: Text("This note has been deleted")
            )
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

