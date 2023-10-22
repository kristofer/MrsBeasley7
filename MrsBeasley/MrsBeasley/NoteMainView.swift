//
//  NoteMainView.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/22/23.
//

import SwiftUI

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
