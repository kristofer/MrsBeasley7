//
//  BackupManager.swift
//  MrsBeasley
//
//  Created by GitHub Copilot on 1/5/26.
//

import Foundation
import CoreData
import SwiftUI

/// Manages backup and restore operations for the app's Core Data database
class BackupManager {
    
    /// Represents a complete backup of the database
    struct DatabaseBackup: Codable {
        let version: Int
        let createdAt: Date
        let notes: [NoteBackup]
        let tags: [TagBackup]
        let tasks: [TaskBackup]
    }
    
    /// Backup representation of a Note entity
    struct NoteBackup: Codable {
        let uuid: UUID
        let title: String?
        let body: String?
        let timestamp: Date?
        let lastmodified: Date?
        let mimetype: String?
        let archived: Bool
        let published: Bool
        let comments: String?
        let blobBase64: String?
        let tagTitles: [String]
    }
    
    /// Backup representation of a Tag entity
    struct TagBackup: Codable {
        let uuid: UUID
        let title: String?
        let kind: Int32
    }
    
    /// Backup representation of a Task entity
    struct TaskBackup: Codable {
        let id: UUID?
        let name: String?
        let complete: Bool
        let priorityNum: Int32
    }
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    /// Creates a complete backup of the database
    /// - Returns: DatabaseBackup object containing all data
    /// - Throws: Error if backup creation fails
    func createBackup() throws -> DatabaseBackup {
        let notes = try fetchAllNotes()
        let tags = try fetchAllTags()
        let tasks = try fetchAllTasks()
        
        let noteBackups = notes.map { note -> NoteBackup in
            let tagTitles = (note.tags as? Set<Tag>)?.compactMap { $0.title } ?? []
            let blobBase64 = note.blob?.base64EncodedString()
            
            return NoteBackup(
                uuid: note.uuid ?? UUID(),
                title: note.title,
                body: note.body,
                timestamp: note.timestamp,
                lastmodified: note.lastmodified,
                mimetype: note.mimetype,
                archived: note.archived,
                published: note.published,
                comments: note.comments,
                blobBase64: blobBase64,
                tagTitles: tagTitles
            )
        }
        
        let tagBackups = tags.map { tag -> TagBackup in
            TagBackup(
                uuid: tag.uuid ?? UUID(),
                title: tag.title,
                kind: tag.kind
            )
        }
        
        let taskBackups = tasks.map { task -> TaskBackup in
            TaskBackup(
                id: task.id,
                name: task.name,
                complete: task.complete,
                priorityNum: task.priorityNum
            )
        }
        
        return DatabaseBackup(
            version: 1,
            createdAt: Date(),
            notes: noteBackups,
            tags: tagBackups,
            tasks: taskBackups
        )
    }
    
    /// Exports backup to JSON string
    /// - Returns: JSON string representation of the backup
    /// - Throws: Error if encoding fails
    func exportBackupToJSON() throws -> String {
        let backup = try createBackup()
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        
        let data = try encoder.encode(backup)
        guard let jsonString = String(data: data, encoding: .utf8) else {
            throw BackupError.encodingFailed
        }
        
        return jsonString
    }
    
    /// Exports backup to a file URL
    /// - Returns: URL of the created backup file
    /// - Throws: Error if file creation fails
    func exportBackupToFile() throws -> URL {
        let jsonString = try exportBackupToJSON()
        
        let fileName = "MrsBeasley-Backup-\(ISO8601DateFormatter().string(from: Date())).json"
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)
        
        try jsonString.write(to: fileURL, atomically: true, encoding: .utf8)
        
        return fileURL
    }
    
    /// Restores database from a backup JSON string
    /// - Parameter jsonString: JSON string containing the backup data
    /// - Parameter mergeStrategy: How to handle existing data (.replace or .merge)
    /// - Throws: Error if restore fails
    func restoreFromJSON(_ jsonString: String, mergeStrategy: MergeStrategy = .merge) throws {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        guard let data = jsonString.data(using: .utf8) else {
            throw BackupError.decodingFailed
        }
        
        let backup = try decoder.decode(DatabaseBackup.self, from: data)
        
        // Validate backup version
        guard backup.version == 1 else {
            throw BackupError.unsupportedVersion
        }
        
        try restoreBackup(backup, mergeStrategy: mergeStrategy)
    }
    
    /// Restores database from a backup file
    /// - Parameters:
    ///   - fileURL: URL of the backup file
    ///   - mergeStrategy: How to handle existing data
    /// - Throws: Error if restore fails
    func restoreFromFile(_ fileURL: URL, mergeStrategy: MergeStrategy = .merge) throws {
        let jsonString = try String(contentsOf: fileURL, encoding: .utf8)
        try restoreFromJSON(jsonString, mergeStrategy: mergeStrategy)
    }
    
    // MARK: - Private Helper Methods
    
    private func restoreBackup(_ backup: DatabaseBackup, mergeStrategy: MergeStrategy) throws {
        // Create a mapping of tag titles to tag objects for relationship restoration
        var tagMap: [String: Tag] = [:]
        
        // First restore all tags
        for tagBackup in backup.tags {
            let tag: Tag
            
            if mergeStrategy == .merge,
               let existingTag = try findTag(withUUID: tagBackup.uuid) {
                tag = existingTag
                tag.title = tagBackup.title
                tag.kind = tagBackup.kind
            } else {
                tag = Tag(context: context)
                tag.uuid = tagBackup.uuid
                tag.title = tagBackup.title
                tag.kind = tagBackup.kind
            }
            
            if let title = tag.title {
                tagMap[title] = tag
            }
        }
        
        // Then restore all notes with their tag relationships
        for noteBackup in backup.notes {
            let note: Note
            
            if mergeStrategy == .merge,
               let existingNote = try findNote(withUUID: noteBackup.uuid) {
                note = existingNote
            } else {
                note = Note(context: context)
                note.uuid = noteBackup.uuid
            }
            
            note.title = noteBackup.title
            note.body = noteBackup.body
            note.timestamp = noteBackup.timestamp
            note.lastmodified = noteBackup.lastmodified
            note.mimetype = noteBackup.mimetype
            note.archived = noteBackup.archived
            note.published = noteBackup.published
            note.comments = noteBackup.comments
            
            if let blobBase64 = noteBackup.blobBase64 {
                note.blob = Data(base64Encoded: blobBase64)
            }
            
            // Restore tag relationships
            for tagTitle in noteBackup.tagTitles {
                if let tag = tagMap[tagTitle] {
                    note.addToTags(tag)
                }
            }
        }
        
        // Restore tasks
        for taskBackup in backup.tasks {
            let task: Task
            
            if mergeStrategy == .merge,
               let id = taskBackup.id,
               let existingTask = try findTask(withID: id) {
                task = existingTask
            } else {
                task = Task(context: context)
                task.id = taskBackup.id ?? UUID()
            }
            
            task.name = taskBackup.name
            task.complete = taskBackup.complete
            task.priorityNum = taskBackup.priorityNum
        }
        
        // Save changes
        try context.save()
    }
    
    private func fetchAllNotes() throws -> [Note] {
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        return try context.fetch(fetchRequest)
    }
    
    private func fetchAllTags() throws -> [Tag] {
        let fetchRequest = NSFetchRequest<Tag>(entityName: "Tag")
        return try context.fetch(fetchRequest)
    }
    
    private func fetchAllTasks() throws -> [Task] {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        return try context.fetch(fetchRequest)
    }
    
    private func findNote(withUUID uuid: UUID) throws -> Note? {
        let fetchRequest = NSFetchRequest<Note>(entityName: "Note")
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
        fetchRequest.fetchLimit = 1
        return try context.fetch(fetchRequest).first
    }
    
    private func findTag(withUUID uuid: UUID) throws -> Tag? {
        let fetchRequest = NSFetchRequest<Tag>(entityName: "Tag")
        fetchRequest.predicate = NSPredicate(format: "uuid == %@", uuid as CVarArg)
        fetchRequest.fetchLimit = 1
        return try context.fetch(fetchRequest).first
    }
    
    private func findTask(withID id: UUID) throws -> Task? {
        let fetchRequest = NSFetchRequest<Task>(entityName: "Task")
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        return try context.fetch(fetchRequest).first
    }
}

// MARK: - Supporting Types

extension BackupManager {
    enum MergeStrategy {
        case replace  // Delete existing data before restore
        case merge    // Update existing items, add new ones
    }
    
    enum BackupError: LocalizedError {
        case encodingFailed
        case decodingFailed
        case unsupportedVersion
        case invalidData
        
        var errorDescription: String? {
            switch self {
            case .encodingFailed:
                return "Failed to encode backup data"
            case .decodingFailed:
                return "Failed to decode backup data"
            case .unsupportedVersion:
                return "Backup version is not supported"
            case .invalidData:
                return "Backup data is invalid or corrupted"
            }
        }
    }
}
