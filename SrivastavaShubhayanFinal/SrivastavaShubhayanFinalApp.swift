//
//  SrivastavaShubhayanFinalApp.swift
//  SrivastavaShubhayanFinal
//
//  Created by Shubhayan Srivastava on 12/8/25.
//

import SwiftUI

@main
struct SrivastavaShubhayanFinalApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
