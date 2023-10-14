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
    
    var markdown: AttributedString {
//        (try? AttributedString(styledMarkdown: content.body))
        (try? AttributedString(markdown: content.body, options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .inlineOnlyPreservingWhitespace)))
        ?? AttributedString()
    }

    func pdfData() -> Data? {
        return PdfCreator().pdfData(title : self.title,
                                    body: self.markdown)
    }
    
    func clear(){
        self.title = ""
        self.body = ""
    }
}

extension AttributedString {
    init(styledMarkdown markdownString: String) throws {
        var output = try AttributedString(
            markdown: markdownString,
            options: .init(
                allowsExtendedAttributes: true,
                interpretedSyntax: .full,
                failurePolicy: .returnPartiallyParsedIfPossible
            ),
            baseURL: nil
        )

        for (intentBlock, intentRange) in output.runs[AttributeScopes.FoundationAttributes.PresentationIntentAttribute.self].reversed() {
            guard let intentBlock = intentBlock else { continue }
            for intent in intentBlock.components {
                switch intent.kind {
                case .header(level: let level):
                    switch level {
                    case 1:
                        output[intentRange].font = .system(.title).bold()
                    case 2:
                        output[intentRange].font = .system(.title2).bold()
                    case 3:
                        output[intentRange].font = .system(.title3).bold()
                    default:
                        break
                    }
//                case .paragraph:
//                    output[intentRange].font = .system(.body)

                default:
                    break
                }
            }
            
            if intentRange.lowerBound != output.startIndex {
                output.characters.insert(contentsOf: "\n\n", at: intentRange.lowerBound)
            }
        }

        self = output
    }
}
