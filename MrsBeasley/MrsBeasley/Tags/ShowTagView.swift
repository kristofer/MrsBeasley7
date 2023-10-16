//
//  ShowTagView.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/16/23.
//

import SwiftUI

struct ShowTagView: View {
    @ObservedObject var note: Note
    
    var body: some View {
        ScrollView (.horizontal, showsIndicators: false) {
            LazyHStack {
                //Label(" ", systemImage: "tag")
                ForEach(Array(note.tags as? Set<Tag> ?? []), id: \.self) { tag in
                    Text(tag.title ?? "??")
                        .font(.caption)
                        .foregroundColor(Color.accentColor)
                        .padding(2)
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(Color.accentColor, lineWidth: 1)
                        )
                        .padding(1)
                }
            }
        }.frame(height: 28)
    }
}

struct ShowTagView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
