//
//  ProovItApp.swift
//  SrivastavaShubhayanFinal
//
//  Main App Entry Point
//

import SwiftUI

@main
struct ProovItApp: App {
    @StateObject private var appVM = AppViewModel()

    var body: some Scene {
        WindowGroup {
            Group {
                if appVM.isAuthenticated {
                    MainTabView()
                } else {
                    AuthView(appVM: appVM)
                }
            }
            .environmentObject(appVM)
        }
    }
}
