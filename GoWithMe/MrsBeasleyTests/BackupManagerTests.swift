//
//  BackupManagerTests.swift
//  MrsBeasleyTests
//
//  Created by GitHub Copilot on 1/5/26.
//

import XCTest
import CoreData
@testable import MrsBeasley

final class BackupManagerTests: XCTestCase {
    
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    var backupManager: BackupManager!
    
    override func setUpWithError() throws {
        // Create in-memory persistence controller for testing
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        backupManager = BackupManager(context: context)
    }
    
    override func tearDownWithError() throws {
        persistenceController = nil
        context = nil
        backupManager = nil
    }
    
    // MARK: - Backup Creation Tests
    
    func testCreateEmptyBackup() throws {
        let backup = try backupManager.createBackup()
        
        XCTAssertEqual(backup.version, 1, "Backup version should be 1")
        XCTAssertEqual(backup.notes.count, 0, "Empty database should have 0 notes")
        XCTAssertEqual(backup.tags.count, 0, "Empty database should have 0 tags")
        XCTAssertEqual(backup.tasks.count, 0, "Empty database should have 0 tasks")
    }
    
    func testCreateBackupWithNotes() throws {
        // Create test data
        let note1 = Note(context: context, title: "Test Note 1")
        note1.body = "This is test note 1"
        
        let note2 = Note(context: context, title: "Test Note 2")
        note2.body = "This is test note 2"
        
        try context.save()
        
        let backup = try backupManager.createBackup()
        
        XCTAssertEqual(backup.notes.count, 2, "Backup should contain 2 notes")
        XCTAssertTrue(backup.notes.contains { $0.title == "Test Note 1" })
        XCTAssertTrue(backup.notes.contains { $0.title == "Test Note 2" })
    }
    
    func testCreateBackupWithTags() throws {
        // Create test tags
        let tag1 = Tag(context: context, title: "Work")
        tag1.kind = 0
        
        let tag2 = Tag(context: context, title: "Personal")
        tag2.kind = 0
        
        try context.save()
        
        let backup = try backupManager.createBackup()
        
        XCTAssertEqual(backup.tags.count, 2, "Backup should contain 2 tags")
        XCTAssertTrue(backup.tags.contains { $0.title == "Work" })
        XCTAssertTrue(backup.tags.contains { $0.title == "Personal" })
    }
    
    func testCreateBackupWithNoteTagRelationships() throws {
        // Create a note and tags
        let note = Note(context: context, title: "Tagged Note")
        note.body = "Note with tags"
        
        let tag1 = Tag(context: context, title: "Important")
        
        let tag2 = Tag(context: context, title: "Review")
        
        note.addToTags(tag1)
        note.addToTags(tag2)
        
        try context.save()
        
        let backup = try backupManager.createBackup()
        
        XCTAssertEqual(backup.notes.count, 1)
        XCTAssertEqual(backup.tags.count, 2)
        
        let backedUpNote = backup.notes.first!
        XCTAssertEqual(backedUpNote.tagTitles.count, 2)
        XCTAssertTrue(backedUpNote.tagTitles.contains("Important"))
        XCTAssertTrue(backedUpNote.tagTitles.contains("Review"))
    }
    
    func testCreateBackupWithBlobData() throws {
        let note = Note(context: context, title: "Note with Blob")
        
        // Create test blob data
        let testData = "Test PDF content".data(using: .utf8)!
        note.blob = testData
        
        try context.save()
        
        let backup = try backupManager.createBackup()
        
        XCTAssertEqual(backup.notes.count, 1)
        let backedUpNote = backup.notes.first!
        XCTAssertNotNil(backedUpNote.blobBase64)
        
        // Verify blob can be decoded back
        let decodedData = Data(base64Encoded: backedUpNote.blobBase64!)
        XCTAssertEqual(decodedData, testData)
    }
    
    // MARK: - JSON Export Tests
    
    func testExportBackupToJSON() throws {
        // Create test data
        let note = Note(context: context, title: "JSON Test")
        note.body = "Test body"
        
        try context.save()
        
        let jsonString = try backupManager.exportBackupToJSON()
        
        XCTAssertFalse(jsonString.isEmpty)
        XCTAssertTrue(jsonString.contains("JSON Test"))
        XCTAssertTrue(jsonString.contains("Test body"))
        
        // Verify it's valid JSON
        let jsonData = jsonString.data(using: .utf8)!
        XCTAssertNoThrow(try JSONSerialization.jsonObject(with: jsonData))
    }
    
    func testExportBackupToFile() throws {
        // Create test data
        let note = Note(context: context, title: "File Export Test")
        
        try context.save()
        
        let fileURL = try backupManager.exportBackupToFile()
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: fileURL.path))
        XCTAssertTrue(fileURL.lastPathComponent.hasPrefix("MrsBeasley-Backup-"))
        XCTAssertEqual(fileURL.pathExtension, "json")
        
        // Clean up
        try? FileManager.default.removeItem(at: fileURL)
    }
    
    // MARK: - Restore Tests
    
    func testRestoreFromJSON() throws {
        // Create a backup
        let originalNote = Note(context: context, title: "Original Note")
        originalNote.body = "Original body"
        
        try context.save()
        
        let jsonString = try backupManager.exportBackupToJSON()
        
        // Clear the database
        context.delete(originalNote)
        try context.save()
        
        // Verify it's empty
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        XCTAssertEqual(try context.fetch(fetchRequest).count, 0)
        
        // Restore from JSON
        try backupManager.restoreFromJSON(jsonString)
        
        // Verify restoration
        let restoredNotes = try context.fetch(fetchRequest)
        XCTAssertEqual(restoredNotes.count, 1)
        XCTAssertEqual(restoredNotes.first?.title, "Original Note")
        XCTAssertEqual(restoredNotes.first?.body, "Original body")
    }
    
    func testRestoreMergeStrategy() throws {
        // Create original note
        let noteUUID = UUID()
        let originalNote = Note(context: context, title: "Original Title")
        originalNote.body = "Original body"
        originalNote.uuid = noteUUID  // Explicitly set UUID for this test
        
        try context.save()
        
        let jsonString = try backupManager.exportBackupToJSON()
        
        // Modify the note
        originalNote.title = "Modified Title"
        originalNote.body = "Modified body"
        try context.save()
        
        // Restore with merge strategy
        try backupManager.restoreFromJSON(jsonString, mergeStrategy: .merge)
        
        // Should update the existing note (merge strategy)
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        let notes = try context.fetch(fetchRequest)
        
        XCTAssertEqual(notes.count, 1, "Should still have only 1 note")
        XCTAssertEqual(notes.first?.uuid, noteUUID)
        XCTAssertEqual(notes.first?.title, "Original Title", "Title should be restored")
        XCTAssertEqual(notes.first?.body, "Original body", "Body should be restored")
    }
    
    func testRestorePreservesRelationships() throws {
        // Create note with tags
        let note = Note(context: context, title: "Note with Tags")
        
        let tag1 = Tag(context: context, title: "Tag1")
        let tag2 = Tag(context: context, title: "Tag2")
        
        note.addToTags(tag1)
        note.addToTags(tag2)
        
        try context.save()
        
        let jsonString = try backupManager.exportBackupToJSON()
        
        // Clear database
        context.delete(note)
        context.delete(tag1)
        context.delete(tag2)
        try context.save()
        
        // Restore
        try backupManager.restoreFromJSON(jsonString)
        
        // Verify relationships
        let noteFetch = NSFetchRequest<Note>(entityName: "Note")
        let restoredNotes = try context.fetch(noteFetch)
        
        XCTAssertEqual(restoredNotes.count, 1)
        
        let restoredNote = restoredNotes.first!
        let restoredTags = restoredNote.tags as? Set<Tag>
        
        XCTAssertEqual(restoredTags?.count, 2)
        let tagTitles = restoredTags?.compactMap { $0.title } ?? []
        XCTAssertTrue(tagTitles.contains("Tag1"))
        XCTAssertTrue(tagTitles.contains("Tag2"))
    }
    
    func testRestoreWithInvalidJSON() throws {
        let invalidJSON = "{ invalid json }"
        
        XCTAssertThrowsError(try backupManager.restoreFromJSON(invalidJSON)) { error in
            // Should throw decodingFailed error
            if let backupError = error as? BackupManager.BackupError {
                XCTAssertEqual(backupError, .decodingFailed)
            }
        }
    }
    
    // MARK: - Performance Tests
    
    func testBackupPerformanceWithLargeDataset() throws {
        // Create a larger dataset
        for i in 1...100 {
            let note = Note(context: context, title: "Note \(i)")
            note.body = "Body content for note \(i)"
        }
        
        for i in 1...20 {
            let tag = Tag(context: context, title: "Tag \(i)")
        }
        
        try context.save()
        
        measure {
            _ = try? backupManager.createBackup()
        }
    }
    
    func testRestorePerformanceWithLargeDataset() throws {
        // Create dataset and backup
        for i in 1...100 {
            let note = Note(context: context, title: "Note \(i)")
        }
        try context.save()
        
        let jsonString = try backupManager.exportBackupToJSON()
        
        // Clear database
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        try context.save()
        
        measure {
            try? backupManager.restoreFromJSON(jsonString)
        }
    }
}
