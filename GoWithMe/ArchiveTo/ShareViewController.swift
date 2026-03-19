//
//  ShareViewController.swift
//  ArchiveTo
//
//  Created by Kristofer Younger on 10/23/23.
//

import UIKit
import SwiftUI
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    
    private var urlString: String?
    private var textString: String?
    private var pdfString: String?
    private var pdfData: Data?
    
    // Use lightweight extension version to minimize memory usage
    let store = PersistenceController.sharedExtension
    lazy var ctxt = store.container.viewContext
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set background to clear to avoid flash
        view.backgroundColor = .systemBackground
        
        // Load the shared content first
        loadSharedContent()
    }
    
    private func loadSharedContent() {
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let attachments = extensionItem.attachments else {
            showShareUI()
            return
        }
        
        let contentTypeURL = UTType.url.identifier
        let contentTypeFileURL = UTType.fileURL.identifier
        let contentTypeText = UTType.utf8PlainText.identifier
        let contentPDF = UTType.pdf.identifier
        
        // Check for PDF first
        for attachment in attachments {
            if attachment.hasItemConformingToTypeIdentifier(contentPDF) {
                attachment.loadItem(forTypeIdentifier: contentPDF, options: nil) { [weak self] (results, error) in
                    guard error == nil else {
                        print("ERROR loading PDF: \(String(describing: error))")
                        DispatchQueue.main.async { self?.showShareUI() }
                        return
                    }
                    
                    if let url = results as? URL {
                        self?.pdfString = url.absoluteString
                        print("ShareEx PDF URL is \(url.absoluteString)")
                        
                        // Download PDF data if not too large
                        URLSession.shared.downloadTask(with: url) { localURL, _, error in
                            defer {
                                DispatchQueue.main.async { self?.showShareUI() }
                            }
                            
                            guard error == nil, let localURL = localURL else { return }
                            
                            do {
                                let attributes = try FileManager.default.attributesOfItem(atPath: localURL.path)
                                if let fileSize = attributes[.size] as? Int64, fileSize < 10_000_000 {
                                    self?.pdfData = try Data(contentsOf: localURL)
                                    print("ShareEx PDF data loaded: \(fileSize) bytes")
                                } else {
                                    print("ShareEx PDF too large, skipping blob storage")
                                }
                            } catch {
                                print("ShareEx unable to load PDF data: \(error)")
                            }
                        }.resume()
                    } else {
                        DispatchQueue.main.async { self?.showShareUI() }
                    }
                }
                return
            }
            
            if attachment.hasItemConformingToTypeIdentifier(contentTypeURL) {
                attachment.loadItem(forTypeIdentifier: contentTypeURL, options: nil) { [weak self] (results, error) in
                    if let url = results as? URL {
                        self?.urlString = url.absoluteString
                        print("ShareEx URL is \(url.absoluteString)")
                    }
                    DispatchQueue.main.async { self?.showShareUI() }
                }
                return
            }
            
            if attachment.hasItemConformingToTypeIdentifier(contentTypeText) {
                attachment.loadItem(forTypeIdentifier: contentTypeText, options: nil) { [weak self] (results, error) in
                    if let text = results as? String {
                        self?.textString = text
                        print("ShareEx Text is \(text)")
                    }
                    DispatchQueue.main.async { self?.showShareUI() }
                }
                return
            }
        }
        
        // If no supported content found, show UI anyway
        showShareUI()
    }
    
    private func showShareUI() {
        // Create SwiftUI view
        let shareView = ShareExtensionView(
            sharedURL: urlString,
            sharedText: textString,
            sharedPDFData: pdfData
        ) { [weak self] title, notes in
            self?.saveNote(title: title, notes: notes)
        } onCancel: { [weak self] in
            self?.cancel()
        }
        
        // Wrap in UIHostingController
        let hostingController = UIHostingController(rootView: shareView)
        hostingController.view.backgroundColor = .systemBackground
        
        // Add as child view controller
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.view.frame = view.bounds
        hostingController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostingController.didMove(toParent: self)
    }
    
    private func saveNote(title: String, notes: String) {
        let date = Date()
        let finalNotes = notes.isEmpty ? "" : notes
        
        // Determine mimetype based on what was shared
        let mimetype: String
        let body: String
        
        if let urlString = urlString {
            mimetype = UTType.html.preferredMIMEType ?? "text/html"
            body = urlString
        } else if let pdfString = pdfString {
            mimetype = UTType.pdf.preferredMIMEType ?? "application/pdf"
            body = pdfString
        } else if let textString = textString {
            mimetype = UTType.plainText.preferredMIMEType ?? "text/plain"
            body = textString + (finalNotes.isEmpty ? "" : "\n\n\(finalNotes)")
        } else {
            mimetype = UTType.plainText.preferredMIMEType ?? "text/plain"
            body = finalNotes
        }
        
        // Create the note
        store.createNote(
            withTitle: title,
            onDate: date,
            body: body,
            blob: pdfData,
            mimetype: mimetype
        )
        
        // Save changes
        ctxt.flushChanges()
        
        print("✅ Note saved successfully to Mrs. Beasley")
        print("   Title: \(title)")
        print("   Body length: \(body.count)")
        print("   Mimetype: \(mimetype)")
        
        // Complete the request
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    private func cancel() {
        extensionContext?.cancelRequest(withError: NSError(domain: "ShareExtension", code: -1, userInfo: [NSLocalizedDescriptionKey: "User cancelled"]))
    }
}

