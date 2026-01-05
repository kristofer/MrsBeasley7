# Backup & Restore Feature Documentation

## Overview

The MrsBeasley (GoWithMe) app now includes a comprehensive backup and restore feature that allows users to create complete copies of their iCloud-synced database and restore from backups when needed.

## Architecture

### Design Strategy

The backup feature is designed specifically for apps using Core Data with iCloud sync (`NSPersistentCloudKitContainer`). The implementation follows iOS/macOS best practices:

1. **JSON Export Format**: All data is exported as structured JSON, making backups human-readable and portable
2. **Complete Data Coverage**: Backs up all entities: Notes (with attachments), Tags, and Tasks
3. **Relationship Preservation**: Maintains all relationships between entities (e.g., Note-Tag associations)
4. **Merge Strategy**: Default restore behavior merges with existing data, updating duplicates based on UUID
5. **iCloud Compatibility**: Works seamlessly with iCloud sync - changes made during restore are automatically synced

### Components

#### BackupManager.swift

The `BackupManager` class handles all backup and restore operations:

```swift
class BackupManager {
    // Creates complete backup of database
    func createBackup() throws -> DatabaseBackup
    
    // Exports backup to JSON string
    func exportBackupToJSON() throws -> String
    
    // Exports backup to a shareable file
    func exportBackupToFile() throws -> URL
    
    // Restores from JSON string
    func restoreFromJSON(_ jsonString: String, mergeStrategy: MergeStrategy) throws
    
    // Restores from file
    func restoreFromFile(_ fileURL: URL, mergeStrategy: MergeStrategy) throws
}
```

#### Data Structures

- **DatabaseBackup**: Root container with version, timestamp, and all entities
- **NoteBackup**: Note entity with all fields including base64-encoded blobs
- **TagBackup**: Tag entity with kind and title
- **TaskBackup**: Task entity with completion status and priority

#### SettingsView Integration

The Settings UI includes a "Backup & Restore" disclosure group with:
- **Export Backup** button: Creates and shares a JSON backup file
- **Import Backup** button: Imports and merges data from a backup file
- Alert dialogs for success/error feedback

## How to Use

### Creating a Backup

1. Open the app and navigate to Settings (typically via a settings icon)
2. Expand the "Backup & Restore" section
3. Tap "Export Backup"
4. Use the system share sheet to:
   - Save to Files app
   - Share via AirDrop
   - Email to yourself
   - Save to iCloud Drive
   - Export to other apps

The backup file is named: `MrsBeasley-Backup-[ISO8601-timestamp].json`

### Restoring from a Backup

1. Open Settings → Backup & Restore
2. Tap "Import Backup"
3. Select your backup JSON file from:
   - Files app
   - iCloud Drive
   - Local storage
   - Any accessible location
4. Wait for the "Restore Complete" confirmation

**Important**: The restore operation merges with existing data. Items with matching UUIDs will be updated, and new items will be added. No data is deleted during restore.

## Backup File Format

The backup JSON file contains:

```json
{
  "version": 1,
  "createdAt": "2026-01-05T20:00:00Z",
  "notes": [
    {
      "uuid": "...",
      "title": "My Note",
      "body": "Note content",
      "timestamp": "2026-01-01T12:00:00Z",
      "lastmodified": "2026-01-05T10:00:00Z",
      "mimetype": "text/plain",
      "archived": false,
      "published": false,
      "blobBase64": "base64-encoded-data...",
      "tagTitles": ["work", "important"]
    }
  ],
  "tags": [
    {
      "uuid": "...",
      "title": "work",
      "kind": 0
    }
  ],
  "tasks": [
    {
      "id": "...",
      "name": "Complete project",
      "complete": false,
      "priorityNum": 1
    }
  ]
}
```

## Technical Details

### Migration Safety

The backup system is designed with migration safety in mind:

1. **Version Field**: Each backup includes a version number for future migration support
2. **UUID-based Matching**: Uses UUIDs to identify and update existing entities
3. **Additive Changes**: Restore never deletes data, only adds or updates
4. **Error Handling**: Comprehensive error handling with user-friendly messages

### iCloud Sync Considerations

- **Automatic Sync**: All restored data automatically syncs to iCloud
- **Conflict Resolution**: Uses Core Data's merge policy (`NSMergeByPropertyObjectTrumpMergePolicy`)
- **History Tracking**: Maintains persistent history tracking for CloudKit sync
- **Remote Changes**: Automatically merges changes from parent (iCloud) context

### Blob Handling

Large binary data (PDFs, images, etc.) stored in Note.blob are:
- Base64-encoded in the backup JSON
- Preserved exactly during restore
- Can significantly increase backup file size

### Data Integrity

- **Relationship Preservation**: Tag-Note relationships are preserved via tag titles
- **UUID Persistence**: Entity UUIDs are maintained across backup/restore
- **Timestamp Preservation**: Original timestamps are preserved
- **Null Safety**: Handles optional fields gracefully

## Error Handling

The backup system includes comprehensive error handling:

- `encodingFailed`: Problem creating JSON from data
- `decodingFailed`: Problem reading backup JSON
- `unsupportedVersion`: Backup version not compatible
- `invalidData`: Backup file corrupted or invalid

All errors are presented to users via alert dialogs with descriptive messages.

## Best Practices

### For Users

1. **Regular Backups**: Create backups regularly, especially before major operations
2. **Multiple Locations**: Store backups in multiple locations (iCloud Drive, local, email)
3. **Version Control**: Keep dated backups to allow restoration to previous states
4. **Test Restores**: Periodically test restore functionality with old backups

### For Developers

1. **Version Management**: Increment backup version when data model changes
2. **Migration Logic**: Add migration code for older backup versions
3. **Testing**: Test backup/restore with various data scenarios
4. **Performance**: Monitor backup file size with large datasets

## Future Enhancements

Potential improvements to consider:

1. **Selective Restore**: Allow restoring only specific entities (notes, tags, or tasks)
2. **Compression**: Add optional GZIP compression for large backups
3. **Encryption**: Add option to encrypt backup files
4. **Scheduled Backups**: Automatic periodic backups
5. **Cloud Backup**: Direct backup to iCloud Drive or other cloud services
6. **Backup History**: Maintain list of previous backups with restore points
7. **Replace Strategy**: Add option to clear database before restore

## Troubleshooting

### Backup Creation Fails
- Check available storage space
- Ensure app has file system access
- Try closing and reopening the app

### Restore Fails
- Verify JSON file is valid (open in text editor)
- Check backup version compatibility
- Ensure sufficient storage for data

### Large File Size
- Backup size is proportional to stored data
- PDFs and images in notes significantly increase size
- Consider archiving old notes before backup

## Implementation Notes

The backup feature integrates seamlessly with the existing app architecture:
- Uses `NSManagedObjectContext` from `PersistenceController.shared`
- Respects Core Data merge policies and sync settings
- Compatible with iCloud sync (`NSPersistentCloudKitContainer`)
- Works on both iOS and macOS (Catalyst) platforms
