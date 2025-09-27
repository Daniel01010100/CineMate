//
//  CinemateApp.swift
//  Cinemate
//
//  Created by YUDONG LU on 14/9/2025.
//

import SwiftUI

@main
struct CinemateApp: App {
    var cmvm: CineMateViewModel = CineMateViewModel()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView(cmvm: cmvm)
        }
    }
}
