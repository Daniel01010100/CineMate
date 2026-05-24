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
    var isFavourite: Bool = false
    var moviePosterURLSnapshot: String? = nil
    var movieTitle: String? = nil
    var movieGenres: [Genres] = []
    var cinemaId: UUID? = nil
    var dateWatched: Date? = nil
    var viewingFormat: [ViewingFormat] = []
    var userRating: Double? = nil
    var review: String? = nil
    var companions: [CompanionModel] = []
    
    init() {}
    
    init(_ movieId: Int, _ isFourite: Bool = false, _ posterPath: String? = nil, _ title: String? = nil, _ movieGenres: [Genres], _ cinemaId: UUID? = nil,
         _ date: Date? = nil, _ format: [ViewingFormat] = [], _ rating: Double? = nil, _ review: String? = nil, _ companions: [CompanionModel] = []) {
        self.movieId = movieId
        self.isFavourite = isFourite
        self.moviePosterURLSnapshot = posterPath
        self.movieTitle = title
        self.movieGenres = movieGenres
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

struct CompanionModel: Codable, Equatable, Hashable {
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

extension MovieRecords {
    var posterURL: URL? {
        guard let path = moviePosterURLSnapshot, !path.isEmpty else {
            return nil
        }
        
        if path.hasPrefix("http") {
            return URL(string: path)
        }
        
        return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
    }
    
    var watchedDateText: String {
        guard let dateWatched else {
            return "Unknown date"
        }
        return dateWatched.formatted(date: .abbreviated, time: .omitted)
    }
    
    var ratingText: String {
        guard let userRating else {
            return "Not rated"
        }
        return String(format: "%.1f / 5", userRating)
    }
    
    var companionText: String {
        let names = companions.compactMap { companion in
            companion.name?.trimmingCharacters(in: .whitespacesAndNewlines)
        }.filter { !$0.isEmpty }
        
        return names.isEmpty ? "Solo watch" : "With \(names.joined(separator: ", "))"
    }
}
