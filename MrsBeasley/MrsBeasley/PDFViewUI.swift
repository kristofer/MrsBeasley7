//
//  PDFViewUI.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/14/23.
//

import SwiftUI
import PDFKit

struct PDFViewUI : UIViewRepresentable {

    private var data: Data?
    
    private let autoScales : Bool
    
    init(data : Data?, autoScales : Bool = true ) {
        self.data = data
        self.autoScales = autoScales
    }

    func makeUIView(context: Context) -> PDFView {
        let pdfView = PDFView()

        pdfView.autoScales =  self.autoScales
       
        if let data = self.data {
            pdfView.document = PDFDocument(data: data)
        }
        
        return pdfView
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        // Empty
    }
}

struct PDFViewUI_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
