//
//  SelectTag.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/22/23.
//

import SwiftUI

struct SelectTag: View {
    @State var isSelected: Bool
    
    @ObservedObject var tag: Tag
    @ObservedObject var note: Note
    
    init(isSelected: Bool, tag: Tag, note: Note) {
        self.isSelected = isSelected
        self.tag = tag
        self.note = note
//        if let tags = note.tags {
//            //print("relationship \(tag.title!) \(tags.contains(tag))")
//            self.isSelected = tags.contains(tag)
//        }else {
//            self.isSelected = false
//        }
    }
    
    var body: some View {
        Button {
            isSelected.toggle()
            if isSelected {
                note.addToTags(self.tag)
            } else {
                note.removeTag(self.tag)
            }
        } label: {
            Text(tag.title ?? "bogus tag")
                .foregroundColor(isSelected ? .white : .accentColor)
                .padding(EdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10))
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(isSelected ? .accentColor : .white)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? .white : .accentColor, lineWidth: 1)
                )
        }
    }
}
