//
//  PDFPreviewView.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/14/23.
//

import SwiftUI

struct PDFPreviewView  : View {
    @EnvironmentObject private var pdfViewModel : PDFViewModel
    
    @State private var showShareSheet : Bool = false
    @Environment(\.dismiss) var dismiss

    var body: some View {
        
        VStack {
            PDFViewUI(data: pdfViewModel.pdfData())
            HStack {
                shareButton()
                Spacer()
                Button("Dismiss", action: { dismiss() })
                    .buttonStyle(.borderedProminent)
            }
            .padding(5)
            Spacer()
        }
        .navigationTitle(Text(pdfViewModel.title))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showShareSheet, content: {
            if let data = pdfViewModel.pdfData() {
                ShareView(activityItems: [data])
            }
        })
    }
    
    private func shareButton() -> some View {
    
        Button(action: {
            self.showShareSheet.toggle()
        }, label: {
            Text("Share")
        })
        .buttonStyle(.borderedProminent)
    }
}

struct PDFPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        PDFPreviewView()
    }
}

struct ShareView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: UIViewControllerRepresentableContext<ShareView>) ->
        UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems,
               applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController,
               context: UIViewControllerRepresentableContext<ShareView>) {
        // empty
    }
}
