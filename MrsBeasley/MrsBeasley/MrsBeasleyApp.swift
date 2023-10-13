//
//  MrsBeasleyApp.swift
//  MrsBeasley
//
//  Created by Kristofer Younger on 10/13/23.
//

import SwiftUI

@main
struct MrsBeasleyApp: App {
    let persistenceController = PersistenceController.shared

    @Environment(\.scenePhase) private var scenePhase

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { phase in
            switch phase {
             case .active:
                 print("active")
             case .inactive:
                 print("inactive")
             case .background:
                 print("background")
                persistenceController.container.viewContext.flushChanges()
             @unknown default:
                 print("unknown ScenePhase error")
             }
         }
    }
}

let noteDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .short
    return formatter
}()

