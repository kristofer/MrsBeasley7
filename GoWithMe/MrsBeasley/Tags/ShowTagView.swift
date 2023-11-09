//
//  ShowTagView.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/16/23.
//

import SwiftUI

struct ShowTagView: View {
    @ObservedObject var note: Note
    @State var showTags = false
    
    var body: some View {
        Button(" \(Image(systemName: "tag")) ") {
            print("tag button")
            showTags.toggle()
        }
        .controlSize(.small)
        .buttonStyle(.borderedProminent)
        HStack {
            ScrollView (.horizontal, showsIndicators: false) {
                //Text("[")
                LazyHStack {
                    ForEach(Array(note.tags as? Set<Tag> ?? [] ), id: \.self) { tag in
                        HStack{
                            Image(systemName: tag.iconForTag())
                                .imageScale(.medium)
                            Text(tag.title ?? "??")
                        }
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
            }
            .frame(height: 28)
        }
        .sheet(isPresented: $showTags) {
                TagHandlerView(note: note)
                .presentationDetents([.medium])
        }
        
    }
}

struct ShowTagView_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}

