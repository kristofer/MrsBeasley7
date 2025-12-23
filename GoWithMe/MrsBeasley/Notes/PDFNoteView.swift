//
//  PDFNoteView.swift
//  GoWithMe
//
//  Created by Kristofer Younger on 1/22/24.
//

import SwiftUI

struct PDFNoteView: View {
    @ObservedObject var note: Note
    var thisUrl: URL
    @State private var moving = false
    @State var url: URL? = nil

    var body: some View {
        VStack {
            NoteDetailHeader(note: note)
            Divider()
            PDFDocumentView(thisUrl: thisUrl)
        }
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    if let newurl = note.loadBlobToData() {
                        self.url = newurl
                        self.moving = true
                    }
                } label: {
                    Text("Export")
                    Image(systemName: "arrow.up.doc.fill")
                }
                .controlSize(.small)
                .fileMover(isPresented: $moving, file: url) { result in
                    switch result {
                    case .success(let url):
                        print("exported \(url.absoluteString)")
                        UIApplication.shared.open(url)
                    case .failure(let error):
                        print(error.localizedDescription)
                    }
                }
                .buttonStyle(.borderedProminent)
                if let newurl = note.loadBlobToData() {
                    ShareLink("Share", item: newurl)
                }
            }
        }
    }
}

#Preview {
    EmptyView()
}
