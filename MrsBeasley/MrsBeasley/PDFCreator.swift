//
//  PDFCreator.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/14/23.
//

import Foundation
import PDFKit
import CoreGraphics


class PdfCreator : NSObject {
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
            kCGPDFContextAuthor: "MrsBeasely"]

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
              withAttributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 24)])
    }
    
    private func addBody (body : String) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .justified
        
        let attributes = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16),
            NSAttributedString.Key.paragraphStyle: paragraphStyle,
            NSAttributedString.Key.foregroundColor : UIColor.gray
        ]
        
        let bodyRect = CGRect(x: 20, y: 70,
                              width: pageRect.width - 40 ,height: pageRect.height - 80)
        body.draw(in: bodyRect, withAttributes: attributes)
    }
}

extension PdfCreator {
    func pdfData( title : String, body: String ) -> Data? {
        if let renderer = self.renderer {

            let data = renderer.pdfData  { ctx in
                ctx.beginPage()
                addTitle(title: title)
                addBody(body: body)
            }
            return data
        }
        return nil
    }
}


