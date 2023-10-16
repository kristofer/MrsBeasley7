//
//  NoteDetail.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import SwiftUI

struct NoteDetail: View {
    @Environment(\.managedObjectContext) var moc
    
    @ObservedObject var note: Note
    @State private var wordCount: Int = 0
    @State private var showPDFPanel = false
    @State var showTags = false
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white)
                .shadow(radius: 10)
            
            
            VStack(alignment: .leading) {
                HStack{
                    NoteDetailHeader(note: note)
                }
                Divider()
                TextEditor(text: $note.body.toUnwrapped(defaultValue: "no body"))
                    .padding(5)
                Divider()
                if wordCount == 0 && note.body != nil {
                    Text("\(countWords(note.body!)) words")
                        .font(.caption).italic()
                } else {
                    Text("\(wordCount) words")
                        .font(.caption).italic()
                }
            }
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .onChange(of: note.body, perform: { newValue in
                if let s = newValue {
                    self.wordCount = countWords(s)
                } else {
                    self.wordCount = 0
                }
                if (note.title == nil || note.title == "") {
                    if let s = note.body {
                        note.title = String(s.prefix(20)) + "..."
                    }
                }
            })
            .padding(10)
            .onDisappear(){
                save()
            }
            .sheet(isPresented: $showPDFPanel) {
                PDFPreviewView()            .environmentObject(PDFViewModel(note: note))
            }
            .sheet(isPresented: $showTags) {
                Form {
                    TagList(note: note)
                    //TagPickerView(note: note, showModal: $showTags)
                }
            }
        }
        .toolbar {
            Button("Category") {
                print("category to be assigned")
                showTags.toggle()
            }
            .buttonStyle(.borderedProminent)
            Button("Help") {
                print("Help tapped!")
            }
            .buttonStyle(.borderedProminent)
        }
        
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button("Save Note", action: {save()})
                    .buttonStyle(.borderedProminent)
                Button("Create PDF", action: {
                    showPDFPanel = true
                })
                .buttonStyle(.borderedProminent)
            }
        }
    }
    
    
    private func countWords(_ s: String) -> Int {
        var c: Int = 0
        let words = s.split {
            $0 == " " ||
            $0.isNewline
        }
        c = words.count
        
        return c
    }
    private func save() {
        moc.flushChanges()
    }
}

struct NoteDetail_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
