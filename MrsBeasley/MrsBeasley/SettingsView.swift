//
//  SettingsView.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/19/23.
//

import SwiftUI

struct SettingsView: View {
    
    @AppStorage("showFooter") private var showFooter = false
    @AppStorage("showTagline") private var showTagline = false
    @AppStorage("showAuthor") private var showAuthor = false
    @AppStorage("showTitle") private var showTitle = false
    @AppStorage("showDate") private var showDate = false
    @AppStorage("yourTagline") private var tagline = "ruit oceano nox"
    @AppStorage("yourAuthor") private var author = "kyounger"
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
        HStack {
            Text("Settings").font(.title2)
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
                DisclosureGroup("Add a Tag") {
                    NewTagView()
                }
                DisclosureGroup("Edit a Tag") {
                    TagList()
                }
                DisclosureGroup("Add a URL") {
                    NewURLView()
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
