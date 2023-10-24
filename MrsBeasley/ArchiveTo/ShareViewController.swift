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
        let fn = Note.allNotes(vc: store.container.viewContext)
        for f in fn {
            print("Note \(f.title) \(f.mimetype)")
        }
        if let string = urlString {
            store.storeNote(withTitle: text,
                            onDate: date,
                            body: string,
                            mimetype: "text/html")
        } else {
            store.storeNote(withTitle: "untitled",
                            onDate: date,
                            body: text,
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
        let contentTypeText = UTType.utf8PlainText.identifier
        
        for attachment in extensionItem.attachments! {
            if attachment.hasItemConformingToTypeIdentifier(contentTypeURL) {
                attachment.loadItem(forTypeIdentifier: contentTypeURL, options: nil, completionHandler: { (results, error) in
                    let url = results as! URL?
                    self.urlString = url!.absoluteString
                    print("Share URL is \(url!.absoluteString)")
                })
            }
            if attachment.hasItemConformingToTypeIdentifier(contentTypeText) {
                attachment.loadItem(forTypeIdentifier: contentTypeText, options: nil, completionHandler: { (results, error) in
                    let text = results as! String
                    self.textString = text
                    print("Share Test is \(text)")
                    _ = self.isContentValid()
                })
            }
        }
    }
    
    func reload(notification: Notification) {
        //let store = PersistenceController.shared

      }
}
