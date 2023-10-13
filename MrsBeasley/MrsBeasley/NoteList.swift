//
//  NoteList.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import SwiftUI

extension Binding {
     func toUnwrapped<T>(defaultValue: T) -> Binding<T> where Value == Optional<T>  {
        Binding<T>(get: { self.wrappedValue ?? defaultValue }, set: { self.wrappedValue = $0 })
    }
}

struct NoteList: View {
        @Environment(\.managedObjectContext) private var viewContext

        @FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)],
            animation: .default)
        private var notes: FetchedResults<Note>

        var body: some View {
            NavigationView {
                List {
                    ForEach(notes, id: \.self) { aNote in
                        NavigationLink {
                            NoteDetail(note: aNote)
                        } label: {
                            NoteRow(note: aNote)
                        }
                    }
                    .onDelete(perform: deleteNotes)
                }
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
                Text("Select an note")
            }
        }

        private func addNote() {
            withAnimation {
                let newNote = Note(context: viewContext)
                newNote.timestamp = Date()

                do {
                    try viewContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }

        private func deleteNotes(offsets: IndexSet) {
            withAnimation {
                offsets.map { notes[$0] }.forEach(viewContext.delete)

                do {
                    try viewContext.save()
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
            }
        }
    }

struct NoteList_Previews: PreviewProvider {
    static var previews: some View {
        NoteList()
    }
}
