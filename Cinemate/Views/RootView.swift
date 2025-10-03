//
//  RootView.swift
//  Cinemate
//
//  Created by YUDONG LU on 18/9/2025.
//

import SwiftUI

struct RootView: View {
    var cmvm: CineMateViewModel
    @State private var defaultTab: Int = 2
    
    var body: some View {
        TabView(selection: $defaultTab) {
            RecordsView(cmvm: cmvm)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Records")
                }
                .tag(0)
            
            MoviesView(cmvm: cmvm)
                .tabItem {
                    Image(systemName: "popcorn.fill")
                    Text("Movies")
                }
                .tag(1)
            DashboardView(cmvm: cmvm)
                .tabItem {
                    Image(systemName: "house")
                    Text("Dashboard")
                }
                .tag(2)
            SettingsView(cmvm: cmvm)
                .tabItem {
                    Image(systemName: "gearshape")
                    Text("Settings")
                }
                .tag(3)
        }
        .tint(cmvm.cinemateColor)
        .onAppear() {
            Task {
                cmvm.loadUserProfile()
            }
        }
    }
}

#Preview {
    RootView(cmvm: CineMateViewModel())
}
