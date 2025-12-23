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
        VStack(alignment: .leading) {
            if let mt = note.mimetype {
                switch mt {
                case UTType.plainText.preferredMIMEType : //"text/plain"
                    NoteTextEditor(note: note)
                case UTType.html.preferredMIMEType : //"text/html" :
                    if let thisUrl = URL(string:note.body!){
                        HTMLNoteView(note: note, thisUrl: thisUrl)
                    }
                case UTType.pdf.preferredMIMEType :
                    if let thisUrl = note.loadBlobToData() {
                        PDFNoteView(note: note, thisUrl: thisUrl)
                    } else {
                        Text("Unable to load PDF")
                            .tint(.red)
                    }
                default:
                    Text("mimetype is not text, html or PDF")
                        .tint(.red)
                    NoteDetailHeader(note: note)
                    FileAssetView(n: note)
                        
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

