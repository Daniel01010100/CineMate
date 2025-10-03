//
//  UserProfile.swift
//  Cinemate
//
//  Created by YUDONG LU on 15/9/2025.
//

import Foundation

struct UserProfile: Codable, Equatable {
    var id: UUID
    var username: String
    var avatar: Data?
    var currentRegion: Regions
    var preferredLanguage: Languages
    
    init() {
        self.id = UUID()
        self.username = ""
        self.currentRegion = .Australia
        self.preferredLanguage = .English
    }
    
    init(_ username: String, _ region: Regions, _ language: Languages) {
        self.id = UUID()
        self.username = username
        self.currentRegion = region
        self.preferredLanguage = language
    }
}
