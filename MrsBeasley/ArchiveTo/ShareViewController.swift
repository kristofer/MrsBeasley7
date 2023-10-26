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
        let store = PersistenceController.shared
        //        let fn = Note.allNotes(vc: store.container.viewContext)
        //        for f in fn {
        //            print("Note \(f.title) \(f.mimetype)")
        //        }
        
        
        if let string = urlString {
            store.storeNote(withTitle: text,
                            onDate: date,
                            body: string,
                            blob: pdfData,
                            mimetype: "text/html")
        } else if let string = pdfString {
            store.storeNote(withTitle: text,
                            onDate: date,
                            body: string,
                            blob: pdfData,
                            mimetype: UTType.pdf.preferredMIMEType ?? "com.adobe.pdf") //"com.adobe.pdf")
        }
        else
        {
            store.storeNote(withTitle: "untitled",
                            onDate: date,
                            body: text,
                            blob: pdfData,
                            mimetype: "text/plain")
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
                    guard (error == nil) else {
                        print("ERROR in loadItem \(String(describing: error))")
                        return
                    }
                    let url = results as! URL?
                    self.pdfString = url!.absoluteString
                    print("ShareEx PDF URL is \(url!.absoluteString)")
                    if let furl = url {
                        let task = URLSession.shared.downloadTask(with: furl) { localURL, urlResponse, error in
                            do {
                                if let localURL = localURL {
                                    self.pdfData = try Data(contentsOf: localURL)
                                    print("ShareEx pdf data is \(String(describing: self.pdfData?.count)) bytes")
                                }
                            } catch {
                                print("ShareEx unable to load data from local URL")
                            }
                        }
                        task.resume()
                    }
                    
                })
                return
            }
            if attachment.hasItemConformingToTypeIdentifier(contentTypeURL) {
                attachment.loadItem(forTypeIdentifier: contentTypeURL, options: nil, completionHandler: { (results, error) in
                    let url = results as! URL?
                    self.urlString = url!.absoluteString
                    print("ShareEx URL is \(url!.absoluteString)")
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
                    //                    if let url = data as? URL {
                    //                        if url.isFileURL{
                    //                            print("found a FILE URL \(url.absoluteString)")
                    //                            Task.detached { [self] in
                    //                                //    try await
                    //                                try? await Fetching().savePublicItem(url, folio: self.selectedFolio!, viewContext: self.vc, contentNote: ct)
                    //                                //                                    try await Fetching().saveLocalFile(url.absoluteString, folio: self.selectedFolio!, viewContext: self.vc, contentNote: ct)
                    //                            }
                    //                        }
                    //                    } else {
                    //                        // Handle this situation as you prefer
                    //                        print("Failed to load data from provider")
                    //                    }
                }
                return
            }
            
            if attachment.hasItemConformingToTypeIdentifier(contentTypeText) {
                attachment.loadItem(forTypeIdentifier: contentTypeText, options: nil, completionHandler: { (results, error) in
                    let text = results as! String
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
