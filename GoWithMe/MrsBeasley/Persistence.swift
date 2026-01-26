//
//  Persistence.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        var result = PersistenceController(inMemory: true)
        var viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Note(context: viewContext)
            newItem.timestamp = Date()
        }
        result.container.viewContext.flushChanges()
        return result
    }()

    let container: NSPersistentCloudKitContainer

    init(inMemory: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "MrsBeasley")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        let description = container.persistentStoreDescriptions.first
        description?.setOption(true as NSNumber,
                               forKey: NSPersistentHistoryTrackingKey)
        // turn on remote change notifications
        let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
        description?.setOption(true as NSNumber,
                                   forKey: remoteChangeKey)

        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                print("Unresolved error persistence issue \(error), \(error.userInfo)")
            }
        })
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        try? container.viewContext.setQueryGenerationFrom(.current)
    }
    
    func createNote(withTitle title: String,
                   onDate date: Date,
                   body: String,
                   blob: Data?,
                   mimetype: String) { // need mimetype from attachment
        let context = self.container.viewContext
        let note = Note(context: context)
        note.uuid = UUID()
        note.title = title
        note.timestamp = date
        note.lastmodified = date
        note.mimetype = mimetype
        note.body = body
        note.blob = blob
        
    }
    
    //    func fetchNotes() {
    //      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
    //      let dateSort = NSSortDescriptor(key:"date", ascending:false)
    //      fetchRequest.sortDescriptors = [dateSort]
    //      self.fetchedNotes = try! context.fetch(fetchRequest) as! [Note]
    //    }
    
    func delete(context: NSManagedObjectContext, note: Note) {
        let context = self.container.viewContext
        context.delete(note)
        context.flushChanges()
    }
    
    // MARK: - Database File Backup and Restore
    
    /// Creates a file-based backup of the current SQLite database
    /// - Returns: Result indicating success or failure with error message
    func backupDatabaseToFile() -> Result<URL, Error> {
        guard let storeURL = container.persistentStoreDescriptions.first?.url else {
            return .failure(NSError(domain: "PersistenceController", 
                                   code: 1, 
                                   userInfo: [NSLocalizedDescriptionKey: "Store URL not found"]))
        }
        
        let fileManager = FileManager.default
        let backupURL = storeURL.deletingLastPathComponent().appendingPathComponent("MrsBeasley_backup.sqlite")
        
        // Save any pending changes
        container.viewContext.flushChanges()
        
        do {
            // Remove existing backup if present
            if fileManager.fileExists(atPath: backupURL.path) {
                try fileManager.removeItem(at: backupURL)
            }
            
            // Copy the main database to backup
            try fileManager.copyItem(at: storeURL, to: backupURL)
            
            // Also copy WAL and SHM files if they exist
            let walURL = URL(fileURLWithPath: storeURL.path + "-wal")
            let shmURL = URL(fileURLWithPath: storeURL.path + "-shm")
            let backupWalURL = URL(fileURLWithPath: backupURL.path + "-wal")
            let backupShmURL = URL(fileURLWithPath: backupURL.path + "-shm")
            
            if fileManager.fileExists(atPath: walURL.path) {
                do {
                    if fileManager.fileExists(atPath: backupWalURL.path) {
                        try fileManager.removeItem(at: backupWalURL)
                    }
                    try fileManager.copyItem(at: walURL, to: backupWalURL)
                } catch {
                    print("Warning: Failed to backup WAL file: \(error)")
                }
            }
            
            if fileManager.fileExists(atPath: shmURL.path) {
                do {
                    if fileManager.fileExists(atPath: backupShmURL.path) {
                        try fileManager.removeItem(at: backupShmURL)
                    }
                    try fileManager.copyItem(at: shmURL, to: backupShmURL)
                } catch {
                    print("Warning: Failed to backup SHM file: \(error)")
                }
            }
            
            print("Database backed up successfully to: \(backupURL.path)")
            return .success(backupURL)
        } catch {
            print("Failed to backup database: \(error)")
            return .failure(error)
        }
    }
    
    /// Restores the SQLite database from a file-based backup
    /// - Returns: Result indicating success or failure with error message
    func restoreDatabaseFromFile() -> Result<Void, Error> {
        guard let storeURL = container.persistentStoreDescriptions.first?.url else {
            return .failure(NSError(domain: "PersistenceController", 
                                   code: 2, 
                                   userInfo: [NSLocalizedDescriptionKey: "Store URL not found"]))
        }
        
        let fileManager = FileManager.default
        let backupURL = storeURL.deletingLastPathComponent().appendingPathComponent("MrsBeasley_backup.sqlite")
        
        // Check if backup exists
        guard fileManager.fileExists(atPath: backupURL.path) else {
            return .failure(NSError(domain: "PersistenceController", 
                                   code: 3, 
                                   userInfo: [NSLocalizedDescriptionKey: "No backup file found"]))
        }
        
        do {
            // Save any pending changes before restore
            container.viewContext.flushChanges()
            
            // Remove all persistent stores
            for store in container.persistentStoreCoordinator.persistentStores {
                try container.persistentStoreCoordinator.remove(store)
            }
            
            // Remove current database files
            if fileManager.fileExists(atPath: storeURL.path) {
                try fileManager.removeItem(at: storeURL)
            }
            
            let walURL = URL(fileURLWithPath: storeURL.path + "-wal")
            let shmURL = URL(fileURLWithPath: storeURL.path + "-shm")
            
            do {
                try fileManager.removeItem(at: walURL)
            } catch {
                print("Note: WAL file not present or already removed")
            }
            
            do {
                try fileManager.removeItem(at: shmURL)
            } catch {
                print("Note: SHM file not present or already removed")
            }
            
            // Copy backup to main database location
            try fileManager.copyItem(at: backupURL, to: storeURL)
            
            // Copy WAL and SHM files if they exist in backup
            let backupWalURL = URL(fileURLWithPath: backupURL.path + "-wal")
            let backupShmURL = URL(fileURLWithPath: backupURL.path + "-shm")
            
            if fileManager.fileExists(atPath: backupWalURL.path) {
                do {
                    try fileManager.copyItem(at: backupWalURL, to: walURL)
                } catch {
                    print("Warning: Failed to restore WAL file: \(error)")
                }
            }
            
            if fileManager.fileExists(atPath: backupShmURL.path) {
                do {
                    try fileManager.copyItem(at: backupShmURL, to: shmURL)
                } catch {
                    print("Warning: Failed to restore SHM file: \(error)")
                }
            }
            
            // Reload the persistent stores
            if let description = container.persistentStoreDescriptions.first {
                try container.persistentStoreCoordinator.addPersistentStore(
                    ofType: description.type,
                    configurationName: description.configuration,
                    at: storeURL,
                    options: description.options
                )
            }
            
            print("Database restored successfully from: \(backupURL.path)")
            return .success(())
        } catch {
            print("Failed to restore database: \(error)")
            return .failure(error)
        }
    }
    
    // MARK: - JSON Backup and Restore
    
    /// Creates a JSON backup of all notes as a new Note entry
    /// - Returns: Result indicating success with the created backup note, or failure with error
    func backupNotesToJSON() -> Result<Note, Error> {
        let context = self.container.viewContext
        
        do {
            // Fetch all non-backup notes (exclude previous JSON backups)
            let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
            fetchRequest.predicate = NSPredicate(format: "mimetype != %@", "application/json")
            let allNotes = try context.fetch(fetchRequest)
            
            // Encode notes to JSON string
            let jsonString = Note.encodeToJSONString(allNotes)
            
            // Create a new note to store the backup
            let backupNote = Note(context: context)
            backupNote.body = jsonString
            backupNote.timestamp = Date()
            backupNote.lastmodified = Date()
            backupNote.uuid = UUID()
            backupNote.title = "JSON Backup of Notes - \(Date().formatted())"
            backupNote.mimetype = "application/json"
            backupNote.published = false
            backupNote.archived = false
            
            // Save the backup note
            context.flushChanges()
            
            print("JSON backup created successfully: \(backupNote.title ?? "Untitled")")
            return .success(backupNote)
        } catch {
            print("Failed to create JSON backup: \(error)")
            return .failure(error)
        }
    }
    
    /// Restores notes from a JSON backup note
    /// - Parameter backupNote: The note containing the JSON backup
    /// - Returns: Result indicating success with number of notes restored, or failure with error
    /// - Note: This method must be called on PersistenceController.shared because Note.fromJSON()
    ///         internally uses PersistenceController.shared.container.viewContext
    func restoreNotesFromJSON(backupNote: Note) -> Result<Int, Error> {
        guard let jsonString = backupNote.body,
              backupNote.mimetype == "application/json" else {
            return .failure(NSError(domain: "PersistenceController",
                                   code: 4,
                                   userInfo: [NSLocalizedDescriptionKey: "Invalid backup note: not a JSON backup"]))
        }
        
        do {
            // Decode notes from JSON
            // IMPORTANT: fromJSON uses PersistenceController.shared.container.viewContext internally
            // This method should only be called on PersistenceController.shared
            let restoredNotes = Note.fromJSON(s: jsonString)
            
            // The fromJSON method creates notes in the shared context
            // Save the context to persist the restored notes
            container.viewContext.flushChanges()
            
            print("Restored \(restoredNotes.count) notes from JSON backup")
            return .success(restoredNotes.count)
        } catch {
            print("Failed to restore notes from JSON: \(error)")
            return .failure(error)
        }
    }

}
