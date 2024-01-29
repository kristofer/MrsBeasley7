//
//  PDFDocumentView.swift
//  GoWithMe
//
//  Created by Kristofer Younger on 1/22/24.
//

import SwiftUI

struct PDFDocumentView: View {
    var thisUrl: URL

    var body: some View {
        VStack {
            PDFKitView(url: thisUrl)
        }
    }
}

#Preview {
    EmptyView()
}
