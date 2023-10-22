//
//  TagHandlerView.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/22/23.
//

import SwiftUI

struct TagHandlerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss

    //var tag: Tag
    @ObservedObject var note: Note

    var body: some View {
        Group {
            VStack {
                Text("Select Tags")
                    .padding(20)
                TagCloudView(data: Tag.allTags(vc: viewContext)) { tag in
                    SelectTag(isSelected: note.containsTag(tag: tag), tag: tag, note: note)
                }
                .padding()
                Divider()
                Button("Done") {
                    viewContext.flushChanges()
                    dismiss()
                }
            }
        }
        .padding()
    }
}

struct TagHandlerView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
