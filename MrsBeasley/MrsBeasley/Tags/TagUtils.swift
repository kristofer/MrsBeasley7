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
        fetchedTags = try! vc.fetch(fetchRequest) as! [Tag]
//        for t in fetchedTags {
//            tfDebug("\(t.title!), [\(t.kind!)]")
//        }
        return fetchedTags
    }

}

