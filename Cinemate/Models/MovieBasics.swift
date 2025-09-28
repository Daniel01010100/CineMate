//
//  MovieBasics.swift
//  Cinemate
//
//  Created by YUDONG LU on 14/9/2025.
//

import Foundation

struct MovieBasics: Codable {
    var id: Int = 0
    var adult: Bool = true
    var backdropPath: String? = nil
    var genreIds: [Int]? = nil
    var originalLanguage: String? = nil
    var originalTitle: String? = nil
    var overview: String? = nil
    var popularity: Double? = nil
    var posterPath: String? = nil
    var releaseDate: String? = nil
    var title: String? = nil
    var video: Bool = false
    var voteAverage: Double? = nil
    var voteCount: Int? = nil
    
    var posterURL: URL? {
        if let path = posterPath {
            return URL(string: "https://image.tmdb.org/t/p/w500\(path)")
        }
        return nil
    }
    
    init() {}
    
    init(_ details: MovieDetails) {
        self.id = details.id
        self.adult = details.adult
        self.backdropPath = details.backdropPath
        self.genreIds = details.genres?.map(\.self.id)
        self.originalLanguage = details.originalLanguage
        self.originalTitle = details.originalTitle
        self.overview = details.overview
        self.popularity = details.popularity
        self.posterPath = details.posterPath
        self.releaseDate = details.releaseDate
        self.title = details.title
        self.video = details.video
        self.voteAverage = details.voteAverage
        self.voteCount = details.voteCount
    }
}

struct Dates: Codable {
    var maximum: String?
    var minimum: String?
}

struct MovieInfo: Codable {
    var dates: Dates? = nil
    var page: Int = 0
    var results: [MovieBasics]? = nil
    var totalPages: Int? = nil
    var totalResults: Int? = nil
}

