//
//  UserProfile.swift
//  Cinemate
//
//  Created by YUDONG LU on 15/9/2025.
//

import Foundation

struct UserProfile: Codable {
    var id: UUID
    var currentRegion: Regions
    var preferredLanguage: Languages
    
    init() {
        self.id = UUID()
        self.currentRegion = .Australia
        self.preferredLanguage = .English
    }
    
    init(_ region: Regions, _ language: Languages) {
        self.id = UUID()
        self.currentRegion = region
        self.preferredLanguage = language
    }
}
