//
//  PDFCreator.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/14/23.
//

import Foundation
import PDFKit
import CoreGraphics
import SwiftUI

class PdfCreator : NSObject {
    @AppStorage("showFooter") private var showFooter = false
    @AppStorage("showTagline") private var showTagline = false
    @AppStorage("showAuthor") private var showAuthor = false
    @AppStorage("showTitle") private var showTitle = false
    @AppStorage("showDate") private var showDate = false
    @AppStorage("yourTagline") private var tagline: String = ""
    @AppStorage("yourAuthor") private var author: String = ""

    private var pageRect : CGRect
    private var renderer : UIGraphicsPDFRenderer?

    /**
    W: 8.5 inches * 72 DPI = 612 points
    H: 11 inches * 72 DPI = 792 points
    A4 = [W x H] 595 x 842 points
    */
    init(pageRect : CGRect =
        CGRect(x: 0, y: 0, width: (8.5 * 72.0), height: (11 * 72.0))) {
       
        let format = UIGraphicsPDFRendererFormat()
        let metaData = [kCGPDFContextTitle: "untitled PDF",
            kCGPDFContextAuthor: "MrsBeasley"]

        format.documentInfo = metaData as [String: Any]
        self.pageRect = pageRect
        self.renderer = UIGraphicsPDFRenderer(bounds: self.pageRect,
                                             format: format)
        super.init()
    }
}

extension PdfCreator {
    private func addTitle ( title  : String ){
        let textRect = CGRect(x: 20, y: 20,
                         width: pageRect.width - 40 ,height: 40)
        title.draw(in: textRect,
              withAttributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18)])
    }
    
    private func addBody (body : AttributedString) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified

        let nsAttributedString = NSAttributedString(body)

        let bodyRect = CGRect(x: 20, y: 70,
                              width: pageRect.width - 40 ,height: pageRect.height - 80)
        nsAttributedString.draw(in: bodyRect) //, withAttributes: attributes)
        //body.draw(in: bodyRect)
    }
}

extension PdfCreator {
    func pdfData( title : String, body: AttributedString ) -> Data? {
        let attributedString = NSAttributedString(body)

        let printFormatter = UISimpleTextPrintFormatter(attributedText: attributedString)

        let renderer = UIPrintPageRenderer()
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        let pageSize = CGSize(width: 595.2, height: 841.8)
        // create some sensible margins
        let pageMargins = UIEdgeInsets(top: 72, left: 72, bottom: 72, right: 72)

        // calculate the printable rect from the above two
        let printableRect = CGRect(x: pageMargins.left, y: pageMargins.top, width: pageSize.width - pageMargins.left - pageMargins.right, height: pageSize.height - pageMargins.top - pageMargins.bottom)

        // and here's the overall paper rectangle
        let paperRect = CGRect(x: 0, y: 0, width: pageSize.width, height: pageSize.height)

        renderer.setValue(NSValue(cgRect: paperRect), forKey: "paperRect")
        renderer.setValue(NSValue(cgRect: printableRect), forKey: "printableRect")
        
        let pdfData = NSMutableData()

        UIGraphicsBeginPDFContextToData(pdfData, paperRect, nil)
        renderer.prepare(forDrawingPages: NSMakeRange(0, renderer.numberOfPages))
        
        let bounds = UIGraphicsGetPDFContextBounds()
        let textRect = CGRect(x: 30, y: pageSize.height - pageMargins.bottom + 30,
                         width: pageRect.width - 40 ,height: 40)
        
        var personalizedTitle = "" //title + " - kyounger - ruit oceano nox."
        if showTitle {
            personalizedTitle = personalizedTitle + title
        }
        if showDate {
            personalizedTitle = personalizedTitle + " " + noteDateFormatter.string(from: Date.now)
        }
        if showAuthor {
            personalizedTitle = personalizedTitle + " - " + author
        }
        if showTagline {
            personalizedTitle = personalizedTitle + " - " + tagline

        }
        
        for i in 0  ..< renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            if showFooter {
                personalizedTitle.draw(in: textRect,
                                       withAttributes: [NSAttributedString.Key.font: UIFont.italicSystemFont(ofSize: 10)])
            }

            renderer.drawPage(at: i, in: bounds)
        }

        UIGraphicsEndPDFContext()
        
//        if let renderer = self.renderer {
//
//            let data = renderer.pdfData  { ctx in
//                ctx.beginPage()
//                addTitle(title: title)
//                addBody(body: body)
//            }
//            return data
//        }
//        return nil
        return pdfData as Data
    }
}


