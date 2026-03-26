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
        // Check if note is still valid (not deleted)
        if !note.isDeleted && !note.isFault {
            NoteDetailHeader(note: note)
            Divider()
            NoteBodyHeader(note: note)
            Divider()
            WebView(url: thisUrl)
                .toolbar {
                    ShareLink("Share", item: thisUrl)
                    Spacer()
                    // Safely unwrap note.body to prevent crash when note is deleted
                    if let noteBody = note.body, !noteBody.isEmpty,
                       let bodyURL = URL(string: noteBody) {
                        Link(" Open -- \(noteBody)", destination: bodyURL)
                    }
                }
                .padding()
        } else {
            // Note has been deleted, show placeholder
            ContentUnavailableView(
                "Note Deleted",
                systemImage: "trash",
                description: Text("This note has been deleted")
            )
        }
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
