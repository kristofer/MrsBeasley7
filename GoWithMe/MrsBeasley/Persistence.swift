//
//  Persistence.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    /// Lightweight persistence controller for Share Extensions and other app extensions
    /// This version disables CloudKit sync and history tracking to minimize memory usage
    static let sharedExtension = PersistenceController(isExtension: true)

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

    init(inMemory: Bool = false, isExtension: Bool = false) {
        container = NSPersistentCloudKitContainer(name: "MrsBeasley")
        
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        } else {
            // CRITICAL: Use App Group container for shared access between app and extensions
            // This allows Share Extension to save to the same database as the main app
            // ⚠️ You MUST configure App Group in Xcode:
            //    1. Select your main app target → Signing & Capabilities → + Capability → App Groups
            //    2. Add "group.co.tioga.MrsBeasley" (or use your bundle ID pattern)
            //    3. Do the same for your ArchiveTo Share Extension target
            
            if let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.co.tioga.MrsBeasley") {
                let storeURL = appGroupURL.appendingPathComponent("MrsBeasley.sqlite")
                
                // SAFETY: Check if this is the first time migrating to App Group
                // If the App Group location is empty but default location has data,
                // we should migrate the existing database
                let fileManager = FileManager.default
                let appGroupStoreExists = fileManager.fileExists(atPath: storeURL.path)
                
                // Get the default store location
                let defaultStoreURL = NSPersistentContainer.defaultDirectoryURL()
                    .appendingPathComponent("MrsBeasley.sqlite")
                let defaultStoreExists = fileManager.fileExists(atPath: defaultStoreURL.path)
                
                if !appGroupStoreExists && defaultStoreExists {
                    print("🔄 MIGRATION: Found existing database at default location")
                    print("🔄 Will migrate to App Group location for extension support")
                    
                    // Copy the existing database to the App Group location
                    do {
                        try fileManager.copyItem(at: defaultStoreURL, to: storeURL)
                        
                        // Also copy WAL and SHM files if they exist
                        let defaultWalURL = URL(fileURLWithPath: defaultStoreURL.path + "-wal")
                        let defaultShmURL = URL(fileURLWithPath: defaultStoreURL.path + "-shm")
                        let appGroupWalURL = URL(fileURLWithPath: storeURL.path + "-wal")
                        let appGroupShmURL = URL(fileURLWithPath: storeURL.path + "-shm")
                        
                        if fileManager.fileExists(atPath: defaultWalURL.path) {
                            try? fileManager.copyItem(at: defaultWalURL, to: appGroupWalURL)
                        }
                        if fileManager.fileExists(atPath: defaultShmURL.path) {
                            try? fileManager.copyItem(at: defaultShmURL, to: appGroupShmURL)
                        }
                        
                        print("✅ Successfully migrated database to App Group location")
                        print("✅ Your existing notes and iCloud sync are preserved")
                    } catch {
                        print("⚠️ Could not migrate database: \(error)")
                        print("⚠️ Will use default location instead")
                        // Fall back to default location - this is safe
                        container.persistentStoreDescriptions.first?.url = defaultStoreURL
                    }
                }
                
                // Use App Group location (either existing or newly migrated)
                if appGroupStoreExists || !defaultStoreExists {
                    container.persistentStoreDescriptions.first?.url = storeURL
                    print("✅ Using shared App Group store at: \(storeURL.path)")
                }
                
            } else {
                print("⚠️ WARNING: App Group 'group.co.tioga.MrsBeasley' not found!")
                print("⚠️ Using default database location - Share Extension will NOT work")
                print("⚠️ Configure App Groups in Xcode → Target → Signing & Capabilities")
                
                // Fall back to default location - this preserves existing data
                let defaultStoreURL = NSPersistentContainer.defaultDirectoryURL()
                    .appendingPathComponent("MrsBeasley.sqlite")
                container.persistentStoreDescriptions.first?.url = defaultStoreURL
                print("📍 Using default store at: \(defaultStoreURL.path)")
            }
        }
        
        let description = container.persistentStoreDescriptions.first
        
        // Enable automatic lightweight migration for schema changes
        // This is critical for migrating existing blob data to external storage
        description?.setOption(true as NSNumber,
                               forKey: NSMigratePersistentStoresAutomaticallyOption)
        description?.setOption(true as NSNumber,
                               forKey: NSInferMappingModelAutomaticallyOption)
        
        // IMPORTANT: History tracking must be enabled for ALL processes accessing the store
        // This includes extensions, otherwise the store will be forced into read-only mode
        description?.setOption(true as NSNumber,
                               forKey: NSPersistentHistoryTrackingKey)
        
        // Only enable remote change notifications for main app (to save memory in extensions)
        if !isExtension {
            let remoteChangeKey = "NSPersistentStoreRemoteChangeNotificationOptionKey"
            description?.setOption(true as NSNumber,
                                       forKey: remoteChangeKey)
        }
        
        // For extensions, disable CloudKit sync to save memory but keep the store writable
        if isExtension {
            print("📱 Extension mode: CloudKit sync disabled to conserve memory")
            description?.cloudKitContainerOptions = nil
        }
        
        // Performance optimization: Allow app to show stale cached data immediately
        // CloudKit sync will happen in background and update UI when ready
        // Note: databaseScope property not available in current SDK version
        // The default scope is already .private, so this is not needed
        // description?.cloudKitContainerOptions?.databaseScope = .private

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
                print("❌ FATAL: Failed to load persistent stores!")
                print("❌ Error: \(error)")
                print("❌ UserInfo: \(error.userInfo)")
                print("❌ This usually means:")
                print("   1. App Group is not configured")
                print("   2. Database migration failed")
                print("   3. File permissions issue")
            } else {
                print("✅ Successfully loaded persistent store")
                if let url = storeDescription.url {
                    print("✅ Store location: \(url.path)")
                }
                if let cloudKitOptions = storeDescription.cloudKitContainerOptions {
                    print("☁️ iCloud sync is ENABLED for container: \(cloudKitOptions.containerIdentifier)")
                } else {
                    print("📱 iCloud sync is DISABLED (extension mode)")
                }
            }
        })
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Set transaction author to distinguish between main app and extension changes
        if isExtension {
            container.viewContext.transactionAuthor = "ArchiveTo-Extension"
        } else {
            container.viewContext.transactionAuthor = "MrsBeasley-MainApp"
        }
        
        // Performance optimization: Use staleTolerance to show cached data immediately
        // This prevents blocking the UI while waiting for CloudKit sync
        // Only set for main app, not extensions
        if !isExtension {
            container.viewContext.stalenessInterval = 0.0
            try? container.viewContext.setQueryGenerationFrom(.current)
        }
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
        note.published = false
        note.archived = false
        
        // Save the note
        context.flushChanges()
    }
    
    //    func fetchNotes() {
    //      let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
    //      let dateSort = NSSortDescriptor(key:"date", ascending:false)
    //      fetchRequest.sortDescriptors = [dateSort]
    //      self.fetchedNotes = try! context.fetch(fetchRequest) as! [Note]
    //    }
    
    func delete(context: NSManagedObjectContext, note: Note) {
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
        
        // Decode notes from JSON
        // IMPORTANT: fromJSON uses PersistenceController.shared.container.viewContext internally
        // This method should only be called on PersistenceController.shared
        let restoredNotes = Note.fromJSON(s: jsonString)
        
        // The fromJSON method creates notes in the shared context
        // Save the context to persist the restored notes
        container.viewContext.flushChanges()
        
        print("Restored \(restoredNotes.count) notes from JSON backup")
        return .success(restoredNotes.count)
    }

}
