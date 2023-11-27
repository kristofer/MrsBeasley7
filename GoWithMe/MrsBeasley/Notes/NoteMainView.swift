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
            if let mt = note.mimetype {
                switch mt {
                case "text/plain" :
                    NoteTextEditor(note: note)
                    //                    } else {
                    //                    }
                case "text/html" :
                    if let thisUrl = URL(string:note.body!){
                        NoteDetailHeader(note: note)
                        WebView(url: thisUrl)
                            .toolbar {
                            ShareLink("Share", item: thisUrl)
                            Spacer()
                            Link(" Open -- \(note.body!)", destination: URL(string: note.body!)!)
                        }
                        .padding()
                    }
                    //                    }
                case UTType.pdf.preferredMIMEType :
                    if let newurl = note.loadBlobToData() {
                        NoteDetailHeader(note: note)
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
                                    if let newurl = note.loadBlobToData() {
                                        ShareLink("Share", item: newurl)
                                    }
                                }
                            }
                    } else {
                        Text("Unable to load PDF")
                    }
                    //                    }
                default:
                    NoteDetailHeader(note: note)
                    FileAssetView(n: note)
                        
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        
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


