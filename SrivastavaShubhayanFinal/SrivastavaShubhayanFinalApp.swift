//
//  SrivastavaShubhayanFinalApp.swift
//  SrivastavaShubhayanFinal
//
//  Created by Shubhayan Srivastava on 12/8/25.
//

import SwiftUI

@main
struct SrivastavaShubhayanFinalApp: App {
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
