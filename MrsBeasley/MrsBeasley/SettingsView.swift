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

    @Environment(\.dismiss) var dismiss

    var body: some View {
        HStack {
            Text("Settings").font(.title2)
            Spacer()
            Button("Done", action: { dismiss() })
                .buttonStyle(.borderedProminent)
        }
        GroupBox {
            VStack(alignment: .leading) {
                Text("PDF Footer Options").font(.title2)
                Toggle("Show footer on PDF", isOn: $showFooter)
                Toggle("Show Tagline on footer", isOn: $showTagline)
                Toggle("Show Author on footer", isOn: $showAuthor)
                Toggle("Show Note Title on footer", isOn: $showTitle)
                Toggle("Show Today Date on footer", isOn: $showDate)
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
