//
//  UserProfile.swift
//  Cinemate
//
//  Created by YUDONG LU on 15/9/2025.
//

import Foundation

struct UserProfile: Codable {
    var id: UUID = UUID()
    var currentRegion: ISO_3166_1
    var preferredLanguage: String?
    var favouriteMoviesIds: [Int] = []
    var recordedMovies: [MovieRecords] = []
}
