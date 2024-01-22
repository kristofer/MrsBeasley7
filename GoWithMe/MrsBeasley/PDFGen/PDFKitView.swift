//
//  PDFKitView.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/24/23.
//

import SwiftUI
import PDFKit


struct PDFKitView: UIViewRepresentable {
    var url: URL // new variable to get the URL of the document
    
    func makeUIView(context: UIViewRepresentableContext<PDFKitView>) -> PDFView {
        // Creating a new PDFVIew and adding a document to it
        let pdfView = PDFView()
        pdfView.document = PDFDocument(url: self.url)
        return pdfView
    }
    
    func updateUIView(_ uiView: PDFView, context: UIViewRepresentableContext<PDFKitView>) {
        // we will leave this empty as we don't need to update the PDF
         if uiView.window != nil, !uiView.isFirstResponder {
             //This triggers attribute cycle if not dispatched
             DispatchQueue.main.async {
                 uiView.document = PDFDocument(url: self.url)
                 uiView.becomeFirstResponder()
             }
         }

    }
}
