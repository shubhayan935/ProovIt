//
//  MainTabView.swift
//  SrivastavaShubhayanFinal
//
//  Main Tab Navigation
//

import SwiftUI

enum TabSelection: Int {
    case home = 0
    case social = 1
    case profile = 2
}

struct MainTabView: View {
    @State private var selectedTab: TabSelection = .home

    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "flame.fill")
                }
                .tag(TabSelection.home)

            SocialFeedView()
                .tabItem {
                    Label("Social", systemImage: "person.2.fill")
                }
                .tag(TabSelection.social)

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
                .tag(TabSelection.profile)
        }
        .accentColor(AppColors.primaryGreen)
        .environment(\.selectedTab, $selectedTab)
    }
}

// Environment key for tab selection
private struct SelectedTabKey: EnvironmentKey {
    static let defaultValue: Binding<TabSelection> = .constant(.home)
}

extension EnvironmentValues {
    var selectedTab: Binding<TabSelection> {
        get { self[SelectedTabKey.self] }
        set { self[SelectedTabKey.self] = newValue }
    }
}
