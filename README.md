# MrsBeasley7
a writing app


### Features to add

- search of notes
- display by reverse date
- export (action?)


# Learnings

in swiftui, to edit the fields from a core data object, you need to merely

```swift
    @ObservedObject var note: Note
```

within the detail view.

that's if the list view is set up something like:

```swift
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)],
        animation: .default)
    private var notes: FetchedResults<Note>
```

then down in the list, 

```swift
        NavigationSplitView {
            List(selection: $noteId) {
                ForEach(notes,  id: \.self) { aNote in
                    NoteRow(note: aNote)
                }
                .onDelete(perform: deleteNotes)
            }
// ...
        } detail: {
            if noteId != nil {
                NoteDetail(note: noteId!) // <--- Note adheres to ObservableObject
            } else {
                Text("Choose a note")
            }
        }
```

This will simplify things a great deal in _Folios_

### viewContext changes sync

why not do this everywhere it's needed? usually on the "moc" variable

```swift
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
```