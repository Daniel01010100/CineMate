//
//  MovieRecords.swift
//  Cinemate
//
//  Created by YUDONG LU on 17/9/2025.
//

import Foundation

struct MovieRecords: Identifiable, Codable {
    var id: UUID = UUID()
    var movieId: Int = 0
    var cinemaId: UUID? = nil
    var dateWatched: Date? = nil
    var userRating: Double? = nil
}

