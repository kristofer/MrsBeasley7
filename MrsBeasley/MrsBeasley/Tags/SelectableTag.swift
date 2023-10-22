//
//  SelectableTag.swift
//  HalfRoll
//
//  Created by Kristofer Younger on 8/18/22.
//

import Foundation


// maybe this should go to Tag model
protocol Taggable {
    func attachTag(_ tag: Tag)
    func removeTag(_ tag: Tag)
}
extension Taggable {
    var asTaggable: Taggable {
        get {self as Taggable}
        set {self = newValue as! Self}
    }
}


protocol SelectableTag: Identifiable, Hashable {
    var displayedName: String { get }
    var isSelected: Bool { get set }
    var displayedTag: Tag { get }

    init(displayedTag: Tag)
}

struct SelectableTagModel: SelectableTag, Identifiable {
    
    
    var displayedTag: Tag
    var displayedName: String
    var isSelected: Bool
    let id: UUID
    
    init(displayedTag: Tag) {
        self.displayedTag = displayedTag
        self.id = displayedTag.uuid!
        self.displayedName = displayedTag.title!
        self.isSelected = false

    }
    
    static func == (lhs: SelectableTagModel, rhs: SelectableTagModel) -> Bool {
        lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
    }
}

