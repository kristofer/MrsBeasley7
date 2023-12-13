//
//  NoteUtils.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/16/23.
//

import Foundation
import SwiftUI
import CoreData
import UniformTypeIdentifiers

class Note: NSManagedObject, Codable  {
    enum CodingKeys: CodingKey {
        case body, mimetype, timestamp, title, uuid
    }
    
    convenience init(
        context moc: NSManagedObjectContext,
        title: String
    ) {
        self.init(context: moc)
        self.uuid = UUID()
        self.title = title
        self.timestamp = Date()
        self.lastmodified = Date()
        self.mimetype = "text/plain"
        self.published = false
        self.archived = false
    }
    
    static func createNote(vc: NSManagedObjectContext,
                           title: String, body: String, type: String) -> Note {
        let newNote = Note(context: vc)
        newNote.timestamp = Date()
        newNote.lastmodified = Date()
        newNote.uuid = UUID()
        newNote.body = body
        newNote.title = title
        newNote.mimetype = type
        newNote.published = false
        newNote.archived = false

        return newNote
    }
    
    static func allNotes(vc: NSManagedObjectContext) -> [Note] {
        var fetchedNotes = [Note]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let dateSort = NSSortDescriptor(key:"title", ascending:true)
        fetchRequest.sortDescriptors = [dateSort]
        fetchedNotes = try! vc.fetch(fetchRequest) as! [Note]
        return fetchedNotes
    }

    
    static func encodeToJSONString(_ values: [Note]) -> String {
        //        let saveToURL = URL.userDocumentsURL.appendingPathComponent("OutFileName.json")
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(values)
            //            try data.write(to: saveToURL)""
            return String(decoding: data, as: UTF8.self)
        } catch {
            print(error)
        }
        return "[]"
    }
    
    static func fromJSON(s: String) -> [Note] {
        //        let jsonURL = URL.userDocumentsURL.appendingPathComponent("Filename.json")
        do {
            //            let inData = try Data(contentsOf: jsonURL)
            return try JSONDecoder().decode([Note].self, from: s.data(using: .utf8) ?? Data())
        } catch {
            print("Error!\n\(error)")
            return [Note]()
            // return an empty array on failure after printing the error}
        }
    }
    
    
    required convenience init(from decoder: Decoder) throws {
        let context = PersistenceController.shared.container.viewContext
        
        self.init(context: context)
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        //body, mimetype, timestamp, title, uuid
        self.body = try values.decode(String.self, forKey: .body)
        self.title = try values.decode(String.self, forKey: .title)
        self.mimetype = try values.decode(String.self, forKey: .mimetype)
        self.uuid = try values.decode(UUID.self,
                                      forKey: .uuid)
        self.timestamp = try values.decode(Date.self,
                                           forKey: .timestamp)
        
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(body, forKey: .body)
        try container.encode(title, forKey: .title)
        try container.encode(mimetype, forKey: .mimetype)
        try container.encode(timestamp, forKey: .timestamp)
        try container.encode(uuid, forKey: .uuid)
    }
    
    func containsTag(tag: Tag) -> Bool {
        if let tags = self.tags {
            return tags.contains(tag)
        }
        return false
    }
    
}

extension Note {
    func attachTag(_ tag: Tag) {
        self.addToTags(tag)
    }
    
    func removeTag(_ tag: Tag) {
        self.removeFromTags(tag)
    }
}

extension Note {
    
//    func downloadFile(fileURL: URL, note: Note) {
//        let request = URLRequest(url:  URL(string: fileURL.absoluteString)!)
//        let config = URLSessionConfiguration.default
//        let session =  URLSession(configuration: config)
//        let task = session.dataTask(with: request, completionHandler: {(data, response, error) in
//            if error == nil{
//                if let pdfData = data {
//                }
//            }else{
//                print(error?.localizedDescription ?? "")
//            }
//        }); task.resume()
//    }
    
    func iconForMimetype() -> String {
        switch self.mimetype {
        case  UTType.pdf.preferredMIMEType :
            return "doc.richtext"
        case  UTType.url.preferredMIMEType :
            return "link.icloud"
        case  UTType.html.preferredMIMEType :
            return "bookmark"
        case  UTType.fileURL.preferredMIMEType :
            return "externaldrive"
        case  UTType.plainText.preferredMIMEType :
            return "note.text"

        default:
//print("weird \(self.mimetype)")
           return "doc"
        }
    }
}
