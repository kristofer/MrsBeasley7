//
//  TagUtils.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/21/23.
//

import Foundation
import SwiftUI
import CoreData

class Tag: NSManagedObject  {
    
    public var tagkind: TagKinds {
        get {
            return TagKinds(rawValue: Int(self.kind)) ?? .plain
        }
    }
}

enum TagKinds: Int, CaseIterable { //, Identifiable {
    //var id: ObjectIdentifier
    
    case plain = 0
    case folder
    case bookmark
    case file
    
}

extension Tag {
    convenience init(
      context moc: NSManagedObjectContext,
      title: String
    ) {
        self.init(context: moc)
        self.uuid = UUID()
        self.title = title
        self.kind = 0
    }
    
    func iconForTag() -> String {
        switch self.tagkind {
        case  .plain :
            return "tag"
        case  .folder :
            return "folder"
        case  .bookmark :
            return "bookmark"
        case  .file :
            return "doc"
//        default:
//            //print("weird \(self.mimetype)")
//            return "bookmark"
        }
    }
}

extension Tag {
    static func getTag(context: NSManagedObjectContext, title: String) -> Tag? {
        //tfDebug("running fetch on all tags")
        var fetchedTags = [Tag]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        let dateSort = NSSortDescriptor(key:"title", ascending:true)
        fetchRequest.sortDescriptors = [dateSort]
        fetchRequest.predicate = NSPredicate(
            format: "title = %@", title
        )
        fetchedTags = try! context.fetch(fetchRequest) as! [Tag]
        if let f = fetchedTags.first {
            return f
        }
        return nil
    }

    static func createIfNoExist(context: NSManagedObjectContext, title: String) -> Tag {
        var ex = Tag.getTag(context: context, title: title)
        if ex == nil {
            ex = Tag(context: context, title: title)
            ex?.kind = 0
        }
        return ex!
    }
}

extension Tag {

// need tagsByKind() 

    static func allTags(vc: NSManagedObjectContext) -> [Tag] {
        //tfDebug("running fetch on all tags")
        var fetchedTags = [Tag]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Tag")
        let dateSort = NSSortDescriptor(key:"title", ascending:true)
        fetchRequest.sortDescriptors = [dateSort]
        
        do {
            fetchedTags = try vc.fetch(fetchRequest) as! [Tag]
        } catch {
            fatalError("Failed to fetch all tags (allTags()): \(error)")
        }
//        for t in fetchedTags {
//            tfDebug("\(t.title!), [\(t.kind!)]")
//        }
        return fetchedTags
    }

}

