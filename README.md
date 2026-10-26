# Go With Me

### Was _MrsBeasley7_
a Tioga LifeStream App app

As of 11/9/2023, GoWithMe is now a Tioga LifeStream app.

As of 10/17/2023, v2 is _complete_

__Caution__ there is a weird bug related to adding for a note. App crashes when a category is selected, and a new note is added, and then you immediately select it.
the crash goes right back to the __@main__

So, i suspect it is related to one of the Predicates in the filtering of the notes. I'll have to look into it.
If one of the predicate's interpolated text is nil, I'd bet that's the problem.

And it occured to me that maybe the tag.title is nil?

```swift
        var catPred = NSPredicate(value: true)
        if let tag = tag, tag.title != nil, tag.title != "<All>" {
            catPred = NSPredicate(format: "tags.title CONTAINS[c] %@", tag.title!)
        }
// added that `tag.title != nil` and will see if I get it again.
```

### Features to add

- sort by alpha title? _but do I need it? I have a searchbar_

#### Features Done

- export (action?) and PDF(!)
- search of notes
- tags/categories
- **backup & restore** - complete database backup/restore with iCloud sync support (see [BACKUP_FEATURE.md](BACKUP_FEATURE.md))


# Learnings

## passing CoreData objects to Swiftui

_it turns out, that it was/is __much__ easier than I had ever figured_

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

Comments on the previous six generations of this app. MrsBeasley is a personal piece of software, I'm the only user. 
I remember the first one was written on a Sun workstation in the about 1986. Notably there was a NeXTSTEP version in Objective-C (Ironic, right?) probably V3.
The first Netscape (V4?) one was *terrible* using cgi-bin (yes, and before javascript). Sometime in 2002, moved it to MacOS and that's that.
