//
//  NoteDetail.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import SwiftUI
import Combine

struct NoteTextEditor: View {
    @Environment(\.managedObjectContext) var moc
    
    @ObservedObject var note: Note
    @State private var wordCount: Int = 0
    @State private var showPDFPanel = false
    @State private var editFontsize = 22.0
    
    @State var publisher = PassthroughSubject<String?, Never>()
    @State var delaySeconds = 5.0
    @State private var isShowingFindNavigator = false

        
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(.white)
                .shadow(radius: 10)
                .padding(5)
            
            VStack(alignment: .leading) {
                NoteDetailHeader(note: note)
                Divider()
                 TextEditor(text: $note.body.toUnwrapped(defaultValue: "no body"))
                    .findNavigator(isPresented: $isShowingFindNavigator)
                    .font(.custom("Inconsolata", size: editFontsize))
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
            .onReceive(
                publisher.debounce(
                    for: .seconds(delaySeconds),
                    scheduler: DispatchQueue.main)) { value in
                        if let s = value {
                            self.wordCount = countWords(s)
                        } else {
                            self.wordCount = 0
                        }
                        save()
                        
                    }
                    .onChange(of: note.body, perform: { value in
                        if let value = value {
                            publisher.send(value)
                        }
                    })
                    .padding(10)
                    .onDisappear(){
                        save()
                    }
                    .onAppear() {
                        if UIDevice.current.localizedModel == "iPhone" {
                            self.editFontsize = 16.0
                        } else if UIDevice.current.localizedModel == "iPad" {
                            self.editFontsize = 22.0
                        }
                    }
                    .sheet(isPresented: $showPDFPanel) {
                        PDFPreviewView().environmentObject(PDFViewModel(note: note))
                    }
        }
        .toolbar {
            Text("Ruit Oceano Nox")
                .font(.subheadline).italic()
            Button("Find") {
                isShowingFindNavigator.toggle()
            }
            Button("Save", action: {save()})
                .controlSize(.small)
                .buttonStyle(.borderedProminent)
                .disabled(!moc.hasChanges)
            Button("PDF", action: {
                save()
                
                showPDFPanel = true
            })
            .controlSize(.small)
            .buttonStyle(.borderedProminent)
            
            //            Button("Help") {
            //                print("Help tapped!")
            //            }
            //            .buttonStyle(.borderedProminent)
        }
        
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
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
            note.lastmodified = Date()
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
