//
//  NoteList.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import SwiftUI
import CoreData

//class Note: NSManagedObject {
//}
//
//class Tag: NSManagedObject {
//}
enum SortBy: CaseIterable, Identifiable, CustomStringConvertible {
    case normal
    case alpha
    
    var id: Self { self }
    
    var description: String {
        switch self {
        case .normal:
            return "Date Created"
        case .alpha:
            return "Title (n/a)"
        }
    }
}

struct NoteList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: false)],
        //        predicate: nil,
        animation: .default)
    private var notes: FetchedResults<Note>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Tag.title, ascending: true)],
        //        predicate: nil,
        animation: .default)
    private var tags: FetchedResults<Tag>
    
    @State private var noteId: Note? = nil
    @State private var searchText: String = ""
    @State private var selectedTag: Tag? = nil
    @State private var selectedTags: [Tag] = []
    @State private var selectedSort: SortBy = .normal
    @State var showSettings = false
    @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            ShowTagArrayView(tags: $selectedTags)
                .padding()
                .sheet(isPresented: $showSettings) {
                    SettingsView()
                }

            // Main List
            List(selection: $noteId) {
                ForEach(notes,  id: \.self) { aNote in
                    NoteRow(note: aNote)
                }
                .onDelete(perform: deleteNotes)
//                    Section(header: Text(aTag.title!)) {
//                        NoteSubList(tag: aTag, noteId: $noteId)
//                }
            }
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
                    //print("NO SELECTION")
                    columnVisibility = .all
                }
            }
            //.navigationTitle("Notes")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "")
            .disableAutocorrection(true)
            .autocapitalization(.none)
//            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
//                if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
//                    let _ = provider.loadObject(ofClass: URL.self) { object, error in
//                        if let url = object {
//                            print("DROP a url: \(url)")
//                        }
//                    }
//                    return true
//                }
//                return false
//            }
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
                }
            }
            HStack{
                SortByView(selectedOption: $selectedSort)
                Spacer()
                Button("[Do Backup]") {
                    makeBackup()
                }
            }
        } detail: {
            if noteId != nil {
                NoteMainView(note: noteId!)
            } else {
                Text("Select a Note")
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
            print("setting catPred")
            for t in stags {
                print("catPred \(t.title!)")
                let tPred = NSPredicate(format: "tags.title CONTAINS[c] %@", t.title!)
                buildPred.append(tPred)
            }
        }
        let orPred = NSCompoundPredicate(type: .or, subpredicates: [titlePred, bodyPred])
        buildPred.append(orPred)
        let predicate = NSCompoundPredicate(type: .and, subpredicates: buildPred)
        notes.nsPredicate = predicate
    }
    
    private func addNote() {
        withAnimation {
            let newNote = Note(context: viewContext)
            newNote.timestamp = Date()
            newNote.uuid = UUID()
            newNote.body = ""
            newNote.title = ""
            newNote.mimetype = "text/plain"
            
            let stags = $selectedTags.wrappedValue

            if !stags.isEmpty {
                for t in stags {
                    newNote.addToTags(t)
                }
            }
            viewContext.flushChanges()
            self.searchText = ""
            self.noteId = newNote.self
        }
    }
    
    private func makeBackup() {
        let notearray = Array(notes)
        let newNote = Note(context: viewContext)
        newNote.body = Note.encodeToJSONString(notearray)
        newNote.timestamp = .distantPast //Calendar.current.date(byAdding: .year, value: -23, to: Date())!
        newNote.uuid = UUID()
        newNote.title = "Backup of Notes"
        newNote.mimetype = "text/plain"
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
