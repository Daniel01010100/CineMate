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

