//
//  NoteList.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import SwiftUI
import CoreData

extension Binding {
    func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}

extension NSManagedObjectContext {
    func flushChanges() {
        if self.hasChanges {
            do {
                try self.save()
            } catch {
                let nserror = error as NSError
                print("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }

    }
}

struct NoteList: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)],
        animation: .default)
    private var notes: FetchedResults<Note>
    
    @State private var noteId: Note?
    @State private var searchText: String = ""
    
    var body: some View {
        NavigationSplitView {
            List(selection: $noteId) {
                ForEach(notes,  id: \.self) { aNote in
                    NoteRow(note: aNote)
                }
//                .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "")
//                .onChange(of: $searchText, perform: { _ in
//                    if (searchText != ""){
//                        notes.nsPredicate=NSPredicate(format: "body CONTAINS[c] %@", searchText)
//                    } else {
//                        notes.nsPredicate=nil
//                    }
//                })
                .onDelete(perform: deleteNotes)
            }
            .navigationTitle("Notes")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addNote) {
                        Label("Add Note", systemImage: "plus")
                    }
                }
            }
        } detail: {
            if noteId != nil {
                NoteDetail(note: noteId!)
            } else {
                Text("Choose a note")
            }
        }

    }
    
    private func addNote() {
        withAnimation {
            let newNote = Note(context: viewContext)
            newNote.timestamp = Date()
            newNote.uuid = UUID()
            newNote.body = ""
            newNote.title = ""
            newNote.mimetype = "text/plain"
            viewContext.flushChanges()
        }
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
