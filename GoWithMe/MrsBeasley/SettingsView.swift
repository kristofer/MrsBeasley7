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
    
    @State private var showAlert = false
    @State private var alertTitle = ""
    @State private var alertMessage = ""
    @State private var showRestoreConfirmation = false
    
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
                DisclosureGroup("Database Management") {
                    VStack(alignment: .leading, spacing: 10) {
                        Button("Create Backup") {
                            makeBackup()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Restore from Backup") {
                            showRestoreConfirmation = true
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.orange)
                        
                        Text("Backup creates a copy of your database. Restore replaces your current database with the backup.")
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
        .confirmationDialog("Restore Database", isPresented: $showRestoreConfirmation, titleVisibility: .visible) {
            Button("Restore from Backup", role: .destructive) {
                restoreBackup()
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("This will replace your current database with the backup. This action cannot be undone. Make sure you have a recent backup before proceeding.")
        }
    }
    
    private func makeBackup() {
        let result = PersistenceController.shared.backupDatabase()
        
        switch result {
        case .success(let backupURL):
            alertTitle = "Backup Successful"
            alertMessage = "Database backed up successfully to:\n\(backupURL.lastPathComponent)"
            showAlert = true
        case .failure(let error):
            alertTitle = "Backup Failed"
            alertMessage = "Failed to backup database: \(error.localizedDescription)"
            showAlert = true
        }
    }
    
    private func restoreBackup() {
        let result = PersistenceController.shared.restoreDatabase()
        
        switch result {
        case .success():
            alertTitle = "Restore Successful"
            alertMessage = "Database restored successfully from backup. Please restart the app for changes to take effect."
            showAlert = true
        case .failure(let error):
            alertTitle = "Restore Failed"
            alertMessage = "Failed to restore database: \(error.localizedDescription)"
            showAlert = true
        }
    }
    

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
