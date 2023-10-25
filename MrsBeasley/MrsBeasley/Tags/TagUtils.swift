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
//    static func allTagsSelectable(vc: NSManagedObjectContext) -> [SelectableTagModel] {
//        let ttags = allTags(vc: vc)
//        let tt = Array(ttags).map { SelectableTagModel(displayedTag: $0) }
//        return tt
//    }

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

