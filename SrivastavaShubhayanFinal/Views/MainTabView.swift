//
//  MainTabView.swift
//  SrivastavaShubhayanFinal
//
//  Main Tab Navigation
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "flame.fill")
                }

            SocialFeedView()
                .tabItem {
                    Label("Social", systemImage: "person.2.fill")
                }

            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.crop.circle")
                }
        }
        .accentColor(AppColors.primaryGreen)
    }
}
