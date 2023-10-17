//
//  NoteDetail.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import SwiftUI
import Combine

struct NoteDetail: View {
    @Environment(\.managedObjectContext) var moc
    
    @ObservedObject var note: Note
    @State private var wordCount: Int = 0
    @State private var showPDFPanel = false
    @State var showTags = false
    
    let detector = PassthroughSubject<Void, Never>()
    let publisher: AnyPublisher<Void, Never>
    init(note: Note) {
        self.note = note
        self.publisher = detector
            .debounce(for: .seconds(3), scheduler: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
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
                    .font(.custom("Inconsolata", size: 22.0))
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
            .onReceive(publisher) { save() }
            .onChange(of: note.body, perform: { newValue in
                detector.send()
                if let s = newValue {
                    self.wordCount = countWords(s)
                } else {
                    self.wordCount = 0
                }
//                if (note.title == nil || note.title == "") {
//                    if let s = note.body {
//                        note.title = String(s.prefix(20)) + "..."
//                    }
//                }
            })
            .padding(10)
            .onDisappear(){
                save()
            }
            .onAppear() {
            }
            .sheet(isPresented: $showPDFPanel) {
                PDFPreviewView().environmentObject(PDFViewModel(note: note))
            }
            .sheet(isPresented: $showTags) {
                Form {
                    TagList(note: note)
                    //TagPickerView(note: note, showModal: $showTags)
                }
            }
        }
        .toolbar {
            Text("Ruit Oceano Nox").font(.subheadline).italic()
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
                    .disabled(!moc.hasChanges)
                Button("Create PDF", action: {
                    save()
                    
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
        if moc.hasChanges {
            print("saving...")
            moc.flushChanges()
        } else {
            print("nothing to save.")
        }
    }
}

struct NoteDetail_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
