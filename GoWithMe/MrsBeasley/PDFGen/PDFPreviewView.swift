//
//  PDFPreviewView.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/14/23.
//

import SwiftUI

struct PDFPreviewView  : View {
    @EnvironmentObject private var pdfViewModel : PDFViewModel
    //@Environment(\.exportFiles) var exportAction
    
    @State private var showShareSheet : Bool = false
    @Environment(\.dismiss) var dismiss
    @State private var moving = false
    @State var url: URL? = nil
    
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
        
        HStack {
            Button(action: {
                self.showShareSheet.toggle()
            }, label: {
                Text("Share")
            })
            .buttonStyle(.borderedProminent)
            Button("Export") {
                let tn = (pdfViewModel.title.convertedToSlug() ?? "untitled") + ".pdf" //UUID().uuidString + ".pdf"
                url = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(tn)
                if let data = pdfViewModel.pdfData(), let url = url {
                    (try? data.write(to: url))
                    moving = true
                }
            }
            .fileMover(isPresented: $moving, file: url) { result in
                switch result {
                case .success(let url):
                    print("exported \(url.absoluteString)")
                case .failure(let error):
                    print(error.localizedDescription)
                }
                dismiss()
            }
            .buttonStyle(.borderedProminent)

        }
    }
}


struct PDFPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
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
