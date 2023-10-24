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
    @State private var selectedSort: SortBy = .normal
    @State var showTags = false
    @State var showSettings = false
    @State private var columnVisibility = NavigationSplitViewVisibility.detailOnly

    var body: some View {
        NavigationSplitView(columnVisibility: $columnVisibility) {
            HStack{
                Text("Categories:").font(.body)
                PickerView(tags: Array(tags), selectedTag: $selectedTag)
                    .buttonStyle(.borderedProminent)
                Spacer()
                Button("+ \(Image(systemName: "tag"))") {
                    showTags.toggle()
                }
                .disabled(noteId == nil)
                .controlSize(.small)
                .buttonStyle(.borderedProminent)
            }
            .padding()
            .sheet(isPresented: $showTags) {
                    //TagList()
                    if let note = noteId {
                        TagHandlerView(note: note)
                    }
            }
            .sheet(isPresented: $showSettings) {
                Form {
                    SettingsView()
                }
            }
            // Main List
            List(selection: $noteId) {
                ForEach(notes,  id: \.self) { aNote in
                    NoteRow(note: aNote)
                }
                .onDelete(perform: deleteNotes)
            }
            .onChange(of: $searchText.wrappedValue, perform: { _ in
                setupPredicate()
            })
            .onChange(of: $selectedTag.wrappedValue, perform: { _ in
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
            .navigationTitle("Notes")
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "")
            .disableAutocorrection(true)
            .autocapitalization(.none)
            .onDrop(of: [.fileURL], isTargeted: nil) { providers in
                if let provider = providers.first(where: { $0.canLoadObject(ofClass: URL.self) } ) {
                    let _ = provider.loadObject(ofClass: URL.self) { object, error in
                        if let url = object {
                            print("DROP a url: \(url)")
                        }
                    }
                    return true
                }
                return false
            }
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
        let tag = $selectedTag.wrappedValue
        var titlePred = NSPredicate(value: true)
        var bodyPred = NSPredicate(value: true)
        
        if stext != "" {
            titlePred = NSPredicate(format: "title CONTAINS[c] %@", stext)
            bodyPred = NSPredicate(format: "body CONTAINS[c] %@", stext)
        }
        
        var catPred = NSPredicate(value: true)
        if let tag = tag, tag.title != nil, tag.title != "<All>" {
            print("setting catPred")
            catPred = NSPredicate(format: "tags.title CONTAINS[c] %@", tag.title!)
        }
        
        let orPred = NSCompoundPredicate(type: .or, subpredicates: [titlePred, bodyPred])
        let predicate = NSCompoundPredicate(type: .and, subpredicates: [orPred, catPred])
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
            
            if let tag = $selectedTag.wrappedValue {
                //if let tag = selectedTag {
                if tag.title != "<All>" {
                    print("adding to category \(tag.title!)")
                    newNote.addToTags(tag)
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

struct PickerView : View {
    
    var tags : [Tag]
    @Binding var selectedTag : Tag?
    
//    init(tags: [Tag], selectedTag: Binding<Tag?>) {
//        self.tags = tags
//        
//        if !tags.isEmpty && selectedTag.wrappedValue == nil {
//            self.selectedTag = tags.first!
//        } else {
//            self._selectedTag = selectedTag
//        }
//    }

    var body : some View {
        Picker(selection: $selectedTag, label: Text("Categories")) {
            if selectedTag == nil { // this will work, since there is no initialization to the optional value in your example
                    Text("no tags").tag(Optional<String>(nil)) // is only shown until a selection is made
            }
                ForEach(tags) { tag in
                    Text(tag.title ?? "").tag(tag as Tag?)
                }
        }
        
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
