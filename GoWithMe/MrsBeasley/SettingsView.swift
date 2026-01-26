//
//  SettingsView.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/19/23.
//

import SwiftUI

public class Defaults: ObservableObject {
    @AppStorage("showFooter") public var showFooter = false
    @AppStorage("showTagline") public var showTagline = false
    @AppStorage("showAuthor") public var showAuthor = false
    @AppStorage("showTitle") public var showTitle = false
    @AppStorage("showDate") public var showDate = false
    @AppStorage("yourTagline") public var tagline = "ruit oceano nox"
    @AppStorage("yourAuthor") public var author = "kyounger"
    public static let shared = Defaults()
}

@propertyWrapper
public struct Default<T>: DynamicProperty {
    @ObservedObject private var defaults: Defaults
    private let keyPath: ReferenceWritableKeyPath<Defaults, T>
    public init(_ keyPath: ReferenceWritableKeyPath<Defaults, T>, defaults: Defaults = .shared) {
        self.keyPath = keyPath
        self.defaults = defaults
    }

    public var wrappedValue: T {
        get { defaults[keyPath: keyPath] }
        nonmutating set { defaults[keyPath: keyPath] = newValue }
    }

    public var projectedValue: Binding<T> {
        Binding(
            get: { defaults[keyPath: keyPath] },
            set: { value in
                defaults[keyPath: keyPath] = value
            }
        )
    }
}

struct SettingsView: View {
    
    @Default(\.showFooter) var showFooter
    @Default(\.showTagline) var showTagline
    @Default(\.showAuthor) var showAuthor
    @Default(\.showTitle) var showTitle
    @Default(\.showDate) var showDate
    @Default(\.tagline) var tagline
    @Default(\.author) var author

    @Environment(\.dismiss) var dismiss
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showDatabaseRestoreConfirmation = false
    @State private var showJSONRestoreSheet = false
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Note.timestamp, ascending: true)],
        predicate: NSPredicate(format: "mimetype == %@", "application/json"),
        animation: .default)
    private var jsonBackups: FetchedResults<Note>
    
    var body: some View {
        VStack {
        HStack {
            Text("Settings").font(.title2).foregroundStyle(.accent)
            Spacer()
            Button("Done", action: { dismiss() })
                .buttonStyle(.borderedProminent)
        }
        .padding()
        //VStack(alignment: .leading) {
            List {
                DisclosureGroup("PDF Footer Options") {
                    Toggle("Show footer on PDF", isOn: $showFooter)
                    Toggle("Show Tagline on footer", isOn: $showTagline)
                    HStack {
                        Text("Tagline: ")
                        TextField("Tagline", text: $tagline)
                            .padding()
                            .border(.foreground)
                    }
                    Toggle("Show Author on footer", isOn: $showAuthor)
                    HStack {
                        Text("Author: ")
                        TextField("Author", text: $author)
                            .padding()
                            .border(.foreground)
                    }
                    Toggle("Show Note Title on footer", isOn: $showTitle)
                    Toggle("Show Today Date on footer", isOn: $showDate)
                    Text("_preview of footer_")
                }
                .foregroundStyle(.accent)

                DisclosureGroup("Add a Tag") {
                    NewTagView()
                }
                .foregroundStyle(.accent)
                DisclosureGroup("Edit a Tag") {
                    TagList()
                }
                .foregroundStyle(.accent)
                DisclosureGroup("Add a URL") {
                    NewURLView()
                }
                .foregroundStyle(.accent)
                DisclosureGroup("Database File Backup/Restore") {
                    VStack(alignment: .leading, spacing: 10) {
                        Button("Create Database File Backup") {
                            makeDatabaseFileBackup()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Restore from Database File Backup") {
                            showDatabaseRestoreConfirmation = true
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.orange)
                        
                        Text("Creates a file copy of the SQLite database. Restore replaces your current database with the backup file.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
                .foregroundStyle(.accent)
                
                DisclosureGroup("JSON Notes Backup/Restore") {
                    VStack(alignment: .leading, spacing: 10) {
                        Button("Create JSON Backup Note") {
                            makeJSONBackup()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Restore from JSON Backup Note") {
                            showJSONRestoreSheet = true
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.blue)
                        
                        Text("Creates a special note containing all notes as JSON. Useful for exporting/importing notes.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 5)
                }
                .foregroundStyle(.accent)

            }
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(alertMessage)
        }
        .confirmationDialog("Restore Database from File", isPresented: $showDatabaseRestoreConfirmation, titleVisibility: .visible) {
            Button("Restore from File Backup", role: .destructive) {
                restoreDatabaseFileBackup()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will replace your entire database with the file backup. This action cannot be undone. The app must be restarted after restore.")
        }
        .sheet(isPresented: $showJSONRestoreSheet) {
            JSONRestoreSheet(jsonBackups: Array(jsonBackups)) { selectedBackup in
                restoreFromJSONBackup(backupNote: selectedBackup)
                showJSONRestoreSheet = false
            }
        }
    }
    
    // MARK: - Database File Backup/Restore
    
    private func makeDatabaseFileBackup() {
        let result = PersistenceController.shared.backupDatabaseToFile()
        
        switch result {
        case .success(let backupURL):
            alertTitle = "Database File Backup Successful"
            alertMessage = "Database backed up successfully to:\n\(backupURL.lastPathComponent)"
            showAlert = true
        case .failure(let error):
            alertTitle = "Database File Backup Failed"
            alertMessage = "Failed to backup database: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func restoreDatabaseFileBackup() {
        let result = PersistenceController.shared.restoreDatabaseFromFile()
        
        switch result {
        case .success():
            alertTitle = "Database File Restore Successful"
            alertMessage = "Database restored successfully from file backup.\n\nIMPORTANT: You should close and restart the app now for the changes to fully take effect."
            showAlert = true
        case .failure(let error):
            alertTitle = "Database File Restore Failed"
            alertMessage = "Failed to restore database: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    // MARK: - JSON Backup/Restore
    
    private func makeJSONBackup() {
        let result = PersistenceController.shared.backupNotesToJSON()
        
        switch result {
        case .success(let backupNote):
            alertTitle = "JSON Backup Created"
            alertMessage = "Created backup note: \(backupNote.title ?? "Untitled")"
            showAlert = true
        case .failure(let error):
            alertTitle = "JSON Backup Failed"
            alertMessage = "Failed to create JSON backup: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func restoreFromJSONBackup(backupNote: Note) {
        let result = PersistenceController.shared.restoreNotesFromJSON(backupNote: backupNote)
        
        switch result {
        case .success(let count):
            alertTitle = "JSON Restore Successful"
            alertMessage = "Restored \(count) notes from JSON backup."
            showAlert = true
        case .failure(let error):
            alertTitle = "JSON Restore Failed"
            alertMessage = "Failed to restore from JSON backup: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
}

// MARK: - JSON Restore Sheet

struct JSONRestoreSheet: View {
    let jsonBackups: [Note]
    let onRestore: (Note) -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                if jsonBackups.isEmpty {
                    Text("No JSON backup notes found")
                        .foregroundColor(.secondary)
                } else {
                    ForEach(jsonBackups, id: \.self) { backup in
                        Button(action: {
                            onRestore(backup)
                            dismiss()
                        }) {
                            VStack(alignment: .leading) {
                                Text(backup.title ?? "Untitled Backup")
                                    .font(.headline)
                                Text("Created: \(backup.lastmodified ?? Date(), formatter: noteDateFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select JSON Backup")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
