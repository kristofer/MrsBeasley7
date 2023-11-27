//
//  NoteList.swift
// This is the Beast of the app.
// Too much here.
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import SwiftUI
import CoreData
import UniformTypeIdentifiers

let AppYellow = Color(red: 1.0, green: 1.0, blue: 0.89)


enum SortBy: CaseIterable, Identifiable, CustomStringConvertible {
    case saved
    case normal
    case alpha
    
    var id: Self { self }
    
    var description: String {
        switch self {
        case .normal:
            return "Date Created"
        case .saved:
            return "Date Modified"
        case .alpha:
            return "Title"
        }
    }
}

struct NoteList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.lastmodified, ascending: false)],
        //        predicate: nil,
        animation: .default)
    private var notes: FetchedResults<Note>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.title, ascending: true)],
        animation: .default)
    private var tags: FetchedResults<Tag>
    
    @State private var noteId: Note? = nil
    @State private var searchText: String = ""
    @State private var selectedTag: Tag? = nil
    @State private var selectedTags: [Tag] = []
    @State private var selectedSort: SortBy = .saved
    @State var showSettings = false
    @State var showTasks = false
    @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly
    
    var body: some View {
        
        NavigationSplitView(columnVisibility: $columnVisibility) {
            VStack {
                ShowTagArrayView(tags: $selectedTags)
                    .padding()
                    .sheet(isPresented: $showSettings) {
                        SettingsView()
                    }
                    .sheet(isPresented: $showTasks) {
                        TaskListView()
                    }
                
                // Main List
                List(selection: $noteId) {
                    ForEach(notes,  id: \.self) { aNote in
                        NoteRow(note: aNote)
                    }
                    .onDelete(perform: deleteNotes)
                }
                .background(AppYellow)
                .onChange(of: $searchText.wrappedValue, perform: { _ in
                    setupPredicate()
                })
                .onChange(of: $selectedTags.wrappedValue, perform: { _ in
                    setupPredicate()
                })
                .refreshable {
                }
                .onAppear() {
                    if noteId == nil {
                        columnVisibility = .all
                    }
                }
                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "")
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("\(Image(systemName: "gear"))") {
                            showSettings.toggle()
                        }
                        .controlSize(.small)
                        .buttonStyle(.borderedProminent)
                    }
                    ToolbarItem {
                        Button(action: addNote) {
                            Label("Add Note", systemImage: "plus")
                        }
                        .onDrop(of: ["public.url","public.file-url", "public.text", UTType.pdf.identifier, "public.content"], isTargeted: nil) { providers -> Bool in
                            //print("dropped")
                            print("Actually dropped \(providers)")
                            providers.forEach { item in
                                //print("Actually dropped \(item)")
                                if item.hasItemConformingToTypeIdentifier(UTType.pdf.identifier) {
                                    item.loadDataRepresentation(forTypeIdentifier: UTType.pdf.identifier) { data, error in
                                        guard error == nil else {
                                            print("loading prob \(String(describing: error))")
                                            return
                                        }
                                        let fname = item.suggestedName ?? "untitled pdf"//?.split(separator: ".").map(String.init).first ?? "unknown"
                                        if let data = data {
                                            DispatchQueue.main.async {
                                                self.addPDFWith(title: fname, blob: data)
                                            }
                                        }
                                    }
                                } else if item.hasItemConformingToTypeIdentifier("public.url") {
                                    item.loadDataRepresentation(forTypeIdentifier: "public.url") { data, error in
                                        guard error == nil else {
                                            print("loading prob \(String(describing: error))")
                                            return
                                        }
                                        //let fname = item.suggestedName ?? "No URL"
                                        if let data = data {
                                            let urlstring = String(decoding: data, as: UTF8.self)
                                            DispatchQueue.main.async {
                                                self.addURLWith(title: urlstring, url: urlstring)
                                            }
                                        }
                                    }
                                } else if item.hasItemConformingToTypeIdentifier("public.content") {
                                    item.loadDataRepresentation(forTypeIdentifier: "public.content") { data, error in
                                        guard error == nil else {
                                            print("loading prob \(String(describing: error))")
                                            return
                                        }
                                        let fname = item.suggestedName ?? "No Name"//?.split(separator: ".").map(String.init).first ?? "unknown"
                                        if let data = data {
                                            DispatchQueue.main.async {
                                                self.addFileWith(title: fname, blob: data)
                                            }
                                        }
                                    }
                                } else if item.hasItemConformingToTypeIdentifier("public.text") {
                                    item.loadDataRepresentation(forTypeIdentifier: "public.text") { data, error in
                                        guard error == nil else {
                                            print("loading prob \(String(describing: error))")
                                            return
                                        }
                                        let fname = item.suggestedName?.split(separator: ".").map(String.init).first ?? "No Title"
                                        if let data = data {
                                            DispatchQueue.main.async {
                                                self.addNoteWith(title: fname, body: String(decoding: data, as: UTF8.self))
                                            }
                                        }
                                    }
                                }
                            }
                            return true
                        }

                    }
                }
                HStack{
                    SortByView(selectedOption: $selectedSort)
                        .onChange(of: $selectedSort.wrappedValue, perform: { _ in
                            setupNoteSort()
                        })
                    
                    Spacer()
                    Button("\(Image(systemName: "list.bullet.clipboard")) Tasks") {
                        showTasks.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    
                }
            }

        } detail: {
            Group {
                if noteId != nil {
                    NoteMainView(note: noteId!)
                } else {
                    Text("Select a Note")
                }
            }

        }
    }
    
    
    private func setupPredicate() {
        let stext = $searchText.wrappedValue
        let stags = $selectedTags.wrappedValue
        var titlePred = NSPredicate(value: true)
        var bodyPred = NSPredicate(value: true)
        
        if stext != "" {
            titlePred = NSPredicate(format: "title CONTAINS[c] %@", stext)
            bodyPred = NSPredicate(format: "body CONTAINS[c] %@", stext)
        }
        
        let catPred = NSPredicate(value: true)
        var buildPred: [NSPredicate] = [catPred]
        if !stags.isEmpty {
            for t in stags {
                let tPred = NSPredicate(format: "tags.title CONTAINS[c] %@", t.title!)
                buildPred.append(tPred)
            }
        }
        let orPred = NSCompoundPredicate(type: .or, subpredicates: [titlePred, bodyPred])
        buildPred.append(orPred)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: buildPred)
        notes.nsPredicate = predicate
    }
    
    private func setupNoteSort() {
        if self.selectedSort == .normal {
            notes.sortDescriptors = [SortDescriptor(\Note.timestamp, order: .reverse)]
            return
        }
        if self.selectedSort == .saved {
            notes.sortDescriptors = [SortDescriptor(\Note.lastmodified, order: .reverse)]
            return
        }
        if self.selectedSort == .alpha {
            notes.sortDescriptors = [SortDescriptor(\Note.title, order: .forward)]
            return
        }
    }
    
    private func addNote() {
        withAnimation {
            addNoteWith(title: "", body: "")
        }
    }
    
    private func addURLWith(title: String, url: String) {
        let stags = $selectedTags.wrappedValue
        let newNote = Note.createNote(vc: viewContext, title: title, body: url, type: "text/html")
        if !stags.isEmpty {
            for t in stags {
                newNote.addToTags(t)
            }
        }
        viewContext.flushChanges()
        self.searchText = ""
        self.noteId = newNote.self
    }
    
    private func addPDFWith(title: String, blob: Data) {
        let stags = $selectedTags.wrappedValue
        let newNote = Note.createNote(vc: viewContext, title: title, body: "", type: UTType.pdf.preferredMIMEType!)
        newNote.blob = blob
        if !stags.isEmpty {
            for t in stags {
                newNote.addToTags(t)
            }
        }
        viewContext.flushChanges()
        self.searchText = ""
        self.noteId = newNote.self
    }
    
    private func addFileWith(title: String, blob: Data) {
        let stags = $selectedTags.wrappedValue
        var mimetype = ""
        if let mtype = UTType(filenameExtension: URL(string: title)!.pathExtension)?.preferredMIMEType {
            mimetype = mtype
        }
        else {
            mimetype = "application/octet-stream"
        }
        
        let newNote = Note.createNote(vc: viewContext, title: title, body: "", type: mimetype)
        newNote.blob = blob
        if !stags.isEmpty {
            for t in stags {
                newNote.addToTags(t)
            }
        }
        viewContext.flushChanges()
        self.searchText = ""
        self.noteId = newNote.self
    }
    
    private func addNoteWith(title: String, body: String) {
        let stags = $selectedTags.wrappedValue
        let newNote = Note.createNote(vc: viewContext, title: title, body: body, type: "text/plain")
        if !stags.isEmpty {
            for t in stags {
                newNote.addToTags(t)
            }
        }
        viewContext.flushChanges()
        self.searchText = ""
        self.noteId = newNote.self
    }
    
    private func deleteNotes(offsets: IndexSet) {
        withAnimation {
            offsets.map { notes[$0] }.forEach(viewContext.delete)
            viewContext.flushChanges()
        }
    }
}

struct NoteList_Previews: PreviewProvider {
    static var previews: some View {
        NoteList()
    }
}

struct SortByView: View {
    @Binding var selectedOption: SortBy
    
    var body: some View {
        Picker("Sort By", selection: $selectedOption) {
            ForEach(SortBy.allCases) { option in
                Text(String(describing: option))
                
            }
        }
    }
}

struct SelectedTagsView : View {
    @Binding var selectedOption: SortBy
    
    var body: some View {
        Picker("Sort By", selection: $selectedOption) {
            ForEach(SortBy.allCases) { option in
                Text(String(describing: option))
                
            }
        }
    }
    
}
