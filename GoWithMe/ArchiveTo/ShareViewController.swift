//
//  ShareViewController.swift
//  ArchiveTo
//
//  Created by Kristofer Younger on 10/23/23.
//

import UIKit
import Social
import SwiftUI
import UniformTypeIdentifiers

class ShareViewController: SLComposeServiceViewController {

    private var urlString: String?
    private var textString: String?
    private var pdfString: String?
    private var pdfData: Data?

    /// Maximum PDF blob size accepted by the extension (25 MB).
    /// Larger files would likely exceed the extension memory budget (~120 MB).
    private static let maxBlobBytes = 25 * 1024 * 1024

    // Use lazy initialization so that the (lightweight) PersistenceController is
    // only created when a note is actually about to be saved, not at view-load time.
    private lazy var store = PersistenceController.shared
    private lazy var ctxt = PersistenceController.shared.container.viewContext

    override func isContentValid() -> Bool {
        if urlString != nil || textString != nil {
            if !contentText.isEmpty {
                return true
            }
        }
        return true
    }
    
    override func didSelectPost() {
        guard let text = textView.text else {return}
        
        let date = Date()
        
        if let string = urlString {
            store.createNote(withTitle: text,
                            onDate: date,
                            body: string,
                            blob: pdfData,
                            mimetype:  UTType.html.preferredMIMEType ?? "text/html" )
            ctxt.flushChanges()
        } else if let string = pdfString {
            store.createNote(withTitle: text,
                            onDate: date,
                            body: string,
                            blob: pdfData,
                            mimetype: UTType.pdf.preferredMIMEType ?? "com.adobe.pdf") //"com.adobe.pdf")
            ctxt.flushChanges()
        }
        else
        {
            store.createNote(withTitle: "untitled",
                            onDate: date,
                            body: text,
                            blob: pdfData,
                            mimetype:  UTType.plainText.preferredMIMEType ?? "text/plain")
            ctxt.flushChanges()
        }
        extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }
    
    
    override func configurationItems() -> [Any]! {
        // To add configuration options via table cells at the bottom of the sheet, return an array of SLComposeSheetConfigurationItem here.
        return []
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        NotificationCenter.default.addObserver(forName: Notification.Name.willEnterForegroundNotification, object: nil, queue: nil, using: reload)
        
        let extensionItem = extensionContext?.inputItems[0] as! NSExtensionItem
        let contentTypeURL = UTType.url.identifier
        let contentTypeFileURL = UTType.fileURL.identifier
        let contentTypeText = UTType.utf8PlainText.identifier
        let contentPDF = UTType.pdf.identifier
        
        for attachment in extensionItem.attachments! {
            if attachment.hasItemConformingToTypeIdentifier(contentPDF) {
                attachment.loadItem(forTypeIdentifier: contentPDF, options: nil, completionHandler: { (results, error) in
                    guard error == nil else {
                        print("ERROR in loadItem \(String(describing: error))")
                        return
                    }
                    guard let url = results as? URL else {
                        print("ShareEx PDF: unexpected result type")
                        return
                    }
                    self.pdfString = url.absoluteString
                    print("ShareEx PDF URL is \(url.absoluteString)")
                    do {
                        // Read the PDF directly from its local file URL.
                        // Guard against files that are too large for the extension
                        // memory budget before loading the bytes into RAM.
                        let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey])
                        let fileSize = resourceValues.fileSize ?? 0
                        guard fileSize <= ShareViewController.maxBlobBytes else {
                            print("ShareEx PDF too large (\(fileSize) bytes), skipping blob load")
                            return
                        }
                        self.pdfData = try Data(contentsOf: url)
                        print("ShareEx pdf data is \(String(describing: self.pdfData?.count)) bytes")
                    } catch {
                        print("ShareEx unable to load PDF data: \(error)")
                    }
                })
                return
            }
            if attachment.hasItemConformingToTypeIdentifier(contentTypeURL) {
                attachment.loadItem(forTypeIdentifier: contentTypeURL, options: nil, completionHandler: { (results, error) in
                    guard error == nil, let url = results as? URL else {
                        print("ShareEx URL load error: \(String(describing: error))")
                        return
                    }
                    self.urlString = url.absoluteString
                    print("ShareEx URL is \(url.absoluteString)")
                })
                return
            }
            if attachment.hasItemConformingToTypeIdentifier(contentTypeFileURL) { // was kind
                attachment.loadItem(forTypeIdentifier: contentTypeFileURL,
                                    options: nil) { //[unowned self]
                    (data, error) in
                    // Handle the error here if you want
                    guard error == nil else { return }
                    print("ShareEx found a public-file-url")
                }
                return
            }
            
            if attachment.hasItemConformingToTypeIdentifier(contentTypeText) {
                attachment.loadItem(forTypeIdentifier: contentTypeText, options: nil, completionHandler: { (results, error) in
                    guard error == nil, let text = results as? String else {
                        print("ShareEx text load error: \(String(describing: error))")
                        return
                    }
                    self.textString = text
                    print("ShareEx Text is \(text)")
                    _ = self.isContentValid()
                })
                return
            }
        }
    }
    
    func reload(notification: Notification) {
        //let store = PersistenceController.shared
        
    }
    
    
}
