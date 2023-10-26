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
    
    @State private var moving = false
    @State var url: URL? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            NoteDetailHeader(note: note)
            if let mt = note.mimetype, mt == "text/plain" {
                NoteTextEditor(note: note)
            }
            if let mt = note.mimetype, mt == "text/html" {
                if let thisUrl = URL(string:note.body!){
                    WebView(url: thisUrl)
                    ShareLink("Share", item: thisUrl)
                }
            }
            if let mt = note.mimetype, mt == UTType.pdf.preferredMIMEType {
                if let newurl = note.loadBlobToData() {
                    PDFKitView(url: newurl)
                        .toolbar {
                            ToolbarItemGroup(placement: .bottomBar) {
                                Button("Export") {
                                    if let newurl = note.loadBlobToData() {
                                        self.url = newurl
                                        self.moving = true
                                    }
                                }
                                .controlSize(.small)
                                .fileMover(isPresented: $moving, file: url) { result in
                                    switch result {
                                    case .success(let url):
                                        print("exported \(url.absoluteString)")
                                    case .failure(let error):
                                        print(error.localizedDescription)
                                    }
                                }
                                .buttonStyle(.borderedProminent)
                            }
                        }
                } else {
                    Text("Unable to load PDF")
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        
    }
}

#Preview {
    EmptyView()
}

import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    let url: URL
    
    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }
}


extension Note {
    func loadBlobToData() -> URL? {
        if self.uuid == nil {
            self.uuid = UUID()
        }
        if let pdfData = self.blob, let fname = self.title!.convertedToSlug() {
            let pathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("\(fname).pdf")
            do {
                try pdfData.write(to: pathURL, options: .atomic)
            } catch {
                print("Error while writing blob to local file for display")
            }
            return pathURL
        }
        return nil
    }
    
}
