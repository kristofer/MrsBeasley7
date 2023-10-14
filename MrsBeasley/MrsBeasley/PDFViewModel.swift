//
//  PDFViewer.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/14/23.
//

import SwiftUI

struct Content{
    var title : String = ""
    var body : String = ""
}

class PDFViewModel : ObservableObject {
    @Published var note: Note
    @Published private var content = Content()
    
    init(note: Note, content: Content = Content()) {
        self.note = note
        self.content = content
        self.content.title = note.title ?? "untitled"
        self.content.body = note.body ?? "no body"
    }
    
    var title : String {
        get { content.title }
        set (newTitle){
            content.title = newTitle
        }
    }
    
    var body : String {
        get { content.body }
        set (newBody){
            content.body = newBody
        }
    }
    
    func pdfData() -> Data? {
        return PdfCreator().pdfData(title : self.title,
                                    body: self.body)
    }
    
    func clear(){
        self.title = ""
        self.body = ""
    }
}
