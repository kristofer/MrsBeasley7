//
//  SettingsView.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/19/23.
//

import SwiftUI
import CoreData
import UniformTypeIdentifiers

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
    
    @State private var showingBackupSuccess = false
    @State private var showingBackupError = false
    @State private var showingRestoreConfirmation = false
    @State private var backupErrorMessage = ""
    @State private var isExportingBackup = false
    @State private var backupFileURL: URL?
    @State private var showingFileImporter = false
    
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
                
                DisclosureGroup("Backup & Restore") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Create a complete backup of your notes, tags, and tasks.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Button {
                            exportBackup()
                        } label: {
                            Label("Export Backup", systemImage: "square.and.arrow.up")
                        }
                        .buttonStyle(.bordered)
                        
                        Button {
                            showingFileImporter = true
                        } label: {
                            Label("Import Backup", systemImage: "square.and.arrow.down")
                        }
                        .buttonStyle(.bordered)
                        
                        Text("⚠️ Importing will merge with existing data. Duplicate items may be updated.")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                    }
                    .padding(.vertical, 8)
                }
                .foregroundStyle(.accent)

            }
        }
        .sheet(isPresented: $isExportingBackup) {
            if let url = backupFileURL {
                ShareSheet(items: [url])
            }
        }
        .fileImporter(
            isPresented: $showingFileImporter,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            handleFileImport(result)
        }
        .alert("Backup Created", isPresented: $showingBackupSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your backup has been created successfully.")
        }
        .alert("Backup Error", isPresented: $showingBackupError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(backupErrorMessage)
        }
        .alert("Restore Complete", isPresented: $showingRestoreConfirmation) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Your data has been restored successfully.")
        }
    }
    
    private func exportBackup() {
        let backupManager = BackupManager(context: viewContext)
        
        do {
            let fileURL = try backupManager.exportBackupToFile()
            backupFileURL = fileURL
            isExportingBackup = true
        } catch {
            backupErrorMessage = error.localizedDescription
            showingBackupError = true
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        do {
            guard let selectedFile = try result.get().first else { return }
            
            // Start accessing security-scoped resource
            guard selectedFile.startAccessingSecurityScopedResource() else {
                backupErrorMessage = "Unable to access the selected file"
                showingBackupError = true
                return
            }
            
            defer { selectedFile.stopAccessingSecurityScopedResource() }
            
            let backupManager = BackupManager(context: viewContext)
            try backupManager.restoreFromFile(selectedFile, mergeStrategy: .merge)
            
            showingRestoreConfirmation = true
        } catch {
            backupErrorMessage = error.localizedDescription
            showingBackupError = true
        }
    }
}

// MARK: - Share Sheet for iOS
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: items, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No update needed
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
