//
//  CinemateApp.swift
//  Cinemate
//
//  Created by YUDONG LU on 14/9/2025.
//

import SwiftUI

@main
struct CinemateApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
