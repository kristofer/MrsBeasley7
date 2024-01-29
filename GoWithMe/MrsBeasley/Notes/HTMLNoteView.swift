//
//  HTMLNoteView.swift
//  GoWithMe
//
//  Created by Kristofer Younger on 1/22/24.
//

import SwiftUI

struct HTMLNoteView: View {
    @ObservedObject var note: Note
    var thisUrl: URL
    
    var body: some View {
        NoteDetailHeader(note: note)
        Divider()
        WebView(url: thisUrl)
            .toolbar {
            ShareLink("Share", item: thisUrl)
            Spacer()
            Link(" Open -- \(note.body!)", destination: URL(string: note.body!)!)
        }
        .padding()
    }
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

import SwiftUI
import SafariServices

struct SafariWebView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: Context) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {
        
    }
}



#Preview {
    EmptyView()
}
