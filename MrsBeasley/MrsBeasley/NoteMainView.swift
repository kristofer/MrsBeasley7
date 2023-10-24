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
        VStack {
            NoteDetailHeader(note: note)
            if let mt = note.mimetype, mt == "text/plain" {
                NoteTextEditor(note: note)
            }
            if let mt = note.mimetype, mt == "text/html" {
                WebView(url: URL(string:note.body!)!)
            }
            if let mt = note.mimetype, mt == UTType.pdf.preferredMIMEType {
                if let newurl = note.loadBlobToData() {
                    PDFKitView(url: newurl)
                        .scaledToFill()
                } else {
                    Text("Unable to load PDF")
                }
            }
            
        }
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
        if let pdfData = self.blob {
            let pathURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("test.pdf")
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

//DispatchQueue.main.async {
//    self.webView.delegate = self
//    self.webView.scalesPageToFit = true
//    self.webView.loadRequest(URLRequest(url: pathURL))
//}
//
