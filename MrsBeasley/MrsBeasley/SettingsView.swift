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
                Button("[Do Backup]") {
                    makeBackup()
                }

            }
        }
    }
    
    private func makeBackup() {
//        let notearray = Array(notes)
//        let newNote = Note(context: viewContext)
//        newNote.body = Note.encodeToJSONString(notearray)
//        newNote.timestamp = .distantPast //Calendar.current.date(byAdding: .year, value: -23, to: Date())!
//        newNote.uuid = UUID()
//        newNote.title = "Backup of Notes"
//        newNote.mimetype = "text/plain"
//        viewContext.flushChanges()
//        self.searchText = ""
//        self.noteId = newNote.self
    }
    

}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
