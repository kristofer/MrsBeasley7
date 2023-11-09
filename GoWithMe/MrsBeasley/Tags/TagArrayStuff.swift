//
//  TagArrayStuff.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/30/23.
//

import SwiftUI

struct ShowTagArrayView: View {
    @Binding var tags: [Tag]
    @State var showTags = false
    
    var body: some View {
        HStack {
            Button("\(Image(systemName: "clear"))") {
                tags = []
            }
            .controlSize(.small)
            .buttonStyle(.borderedProminent)
            HStack {
                ScrollView (.horizontal, showsIndicators: false) {
                    //Text("[")
                    LazyHStack {
                        ForEach(Array(tags), id: \.self) { tag in
                            HStack {
                                Image(systemName: tag.iconForTag())
                                    .imageScale(.medium)
                                Text(tag.title ?? "bogus tag")
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
                GeometryReader { proxy in
                    TagArrayHandlerView(tags: $tags)
                        .frame(width: proxy.size.width)
                        //.frame(width: proxy.size.width, height: proxy.size.height)
                }
            }
            Button("\(Image(systemName: "tag"))") {
                showTags.toggle()
            }
            .controlSize(.small)
            .buttonStyle(.borderedProminent)
        }
        
    }
}


struct SelectArrayTag: View {
    @State var isSelected: Bool
    @ObservedObject var tag: Tag
    @Binding var tags: [Tag]
    
    var body: some View {
        Button {
            isSelected.toggle()
            if isSelected {
                tags.append(tag)
            } else {
                tags.remove(at: (tags.firstIndex(of: tag)!))
            }
        } label: {
            HStack {
                Image(systemName: tag.iconForTag())
                    .imageScale(.medium)
                Text(tag.title ?? "bogus tag")
            }
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


struct TagArrayHandlerView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) var dismiss
    
    //var tag: Tag
    @Binding var tags: [Tag]
    
    var body: some View {
        Group {
            VStack {
                Text("Select Tags")
                    .foregroundStyle(.accent)
                    .font(.headline)
                    .padding(20)
                TagCloudView(data: Tag.allTags(vc: viewContext)) { tag in
                    SelectArrayTag(isSelected: tags.contains(tag), tag: tag, tags: $tags)
                }
                .padding()
                Divider()
                Button("Done") {
                    viewContext.flushChanges()
                    dismiss()
                }
                .buttonStyle(.borderedProminent)

            }
        }
        .padding()
        
    }
}
