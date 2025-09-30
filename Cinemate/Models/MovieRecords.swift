//
//  MovieRecords.swift
//  Cinemate
//
//  Created by YUDONG LU on 17/9/2025.
//

import Foundation

struct MovieRecords: Codable, Identifiable {
    var id: UUID = UUID()
    var movieId: Int = 0
    var moviePosterURLSnapshot: String? = nil
    var movieTitle: String? = nil
    var cinemaId: UUID? = nil
    var dateWatched: Date? = nil
    var viewingFormat: [ViewingFormat] = []
    var userRating: Double? = nil
    var review: String? = nil
    var companions: [CompanionModel] = []
    
    init() {}
    
    init(_ movieId: Int, _ posterPath: String? = nil, _ title: String? = nil, _ cinemaId: UUID? = nil, _ date: Date? = nil,
         _ format: [ViewingFormat] = [], _ rating: Double? = nil, _ review: String? = nil, _ companions: [CompanionModel] = []) {
        self.movieId = movieId
        self.moviePosterURLSnapshot = posterPath
        self.movieTitle = title
        self.cinemaId = cinemaId
        self.dateWatched = date
        self.viewingFormat = format
        self.userRating = rating
        self.review = review
        self.companions = companions
    }
}

enum ViewingFormat: String, Codable, CaseIterable, Identifiable, Equatable {
    case standard2D = "2D"
    case threeD = "3D"
    case imax2D = "IMAX 2D"
    case imax3D = "IMAX 3D"
    case dolbyCinema = "Dolby Cinema"
    case fourDX = "4DX"
    case screenX = "ScreenX"
    
    var id: String { self.rawValue }
}

struct CompanionModel: Codable, Equatable {
    var name: String? = nil
    var relationship: String? = nil
    var userId: UUID? = nil
    var isPrimary: Bool = false
    
    init() {}
    
    init(_ name: String? = nil, _ relationship: String? = nil,_ userId: UUID? = nil, _ isPrimary: Bool = false) {
        self.name = name
        self.relationship = relationship
        self.userId = userId
        self.isPrimary = isPrimary
    }
}

