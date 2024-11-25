//
//  NoteDetail.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

struct NoteTextEditor: View {
    @Environment(\.managedObjectContext) var moc
    
    @ObservedObject var note: Note
    @State private var wordCount: Int = 0
    @State private var showPDFPanel = false
    private var editFontsize: CGFloat {
        if UIDevice.current.localizedModel == "iPhone" {
            return 16.0
        } else if UIDevice.runningOnMac {
            return 28.0
        } else if UIDevice.current.localizedModel == "iPad" {
            return 20.0
        }
        return 18.0
    }
    
    @State var publisher = PassthroughSubject<String?, Never>()
    @State var delaySeconds = 5.0
    @State private var isShowingFindNavigator = false

        
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15, style: .continuous)
                .fill(AppYellow)
                .shadow(radius: 10)
                .padding(5)
            
            VStack(alignment: .leading) {
                NoteDetailHeader(note: note)
                Divider()
                if note.published {
                    Text(try! AttributedString(styledMarkdown: note.body ?? "Error", fontSize: 18.0, forPreview: true))
                        .padding(20)
                        .background(.white)
                    Spacer()

                } else {
                    TextEditor(text: $note.body.toUnwrapped(defaultValue: "no body"))
                        .findNavigator(isPresented: $isShowingFindNavigator)
                        .font(.custom("Inconsolata", size: editFontsize))
                        .padding(5)
                        .scrollContentBackground(.hidden) // <- Hide it
                        .background(AppYellow)
//                        .onDrop(of: [.url], delegate: self)
                    
                    // OR use https://github.com/twitter/TwitterTextEditor
                    // there are lots of bugs with long documents in standard component.

                }
                Divider()
                if wordCount == 0 && note.body != nil {
                    Text("\(countWords(note.body!)) words - {font \(editFontsize)}")
                        .font(.caption).italic()
                } else {
                    Text("\(wordCount) words") //- {font \(editFontsize)}")
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
//                    .onAppear() {
//                        if UIDevice.current.localizedModel == "iPhone" {
//                            self.editFontsize = 16.0
//                        } else if UIDevice.current.localizedModel == "iPad" {
//                            self.editFontsize = 22.0
//                        } else if UIDevice.runningOnMac {
//                            self.editFontsize = 28.0
//                        }
//                    }
                    .sheet(isPresented: $showPDFPanel) {
                        PDFPreviewView().environmentObject(PDFViewModel(note: note))
                    }
        }
        .toolbarBackground(Color(red: 0.99, green: 0.96, blue: 0.81))
        .toolbar {
            Text("Ruit Oceano Nox")
                .font(.subheadline).italic()
            Toggle("Publish", isOn: $note.published)
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
            $0.isNewline ||
            $0.isPunctuation
        }
        c = words.count
        
        return c
    }
    private func save() {
        if moc.hasChanges {
            note.lastmodified = Date()
//            print("saving...")
            moc.flushChanges()
        }
//        else {
//            print("nothing to save.")
//        }
    }
}

//extension TextEditor: DropDelegate {
//    public func dropEntered(info: DropInfo) {
//        //self.isDrop = true
//    }
//    public func dropExited(info: DropInfo) {
//        //self.isDrop = false
//    }
//    public func performDrop(info: DropInfo) -> Bool {
//        handleDrop(info)
//    }
//    func handleDrop(_ info: DropInfo) -> Bool {
//        if let provider = info.itemProviders(for: [.url]).first {
//            provider.loadDataRepresentation(
//                forTypeIdentifier: UTType.url.identifier,
//                completionHandler: { data, error in
//                    if let data = data,
//                       let string = String(data: data, encoding: .utf8),
//                       let url = URL(string: string) {
//                        DispatchQueue.main.async {
//                            //self.b
//                        }
//                    }
//                }
//            )
//            
//            return true
//        }
//        
//        return false
//    }
//
//}
struct NoteDetail_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
