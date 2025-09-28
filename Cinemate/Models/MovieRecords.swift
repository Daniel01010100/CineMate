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
    var viewingFormat: [ViewingFormat] = []
    var userRating: Double? = nil
    var review: String? = nil
}

enum ViewingFormat: String, Codable, CaseIterable, Identifiable {
    case standard2D = "2D"
    case threeD = "3D"
    case imax2D = "IMAX 2D"
    case imax3D = "IMAX 3D"
    case dolbyCinema = "Dolby Cinema"
    case dolbyVision = "Dolby Vision"
    case dolbyAtmos = "Dolby Atmos"
    case fourDX = "4DX"
    case screenX = "ScreenX"
    
    var id: String { self.rawValue }
}

