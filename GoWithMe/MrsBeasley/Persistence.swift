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

}
