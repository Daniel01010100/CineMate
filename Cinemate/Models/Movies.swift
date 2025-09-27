//
//  Movies.swift
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

struct Genres: Codable {
    var id: Int = 0
    var name: String? = nil
}

struct ProductionCompany: Codable {
    var id: Int = 0
    var logo_path: String? = nil
    var name: String? = nil
    var origin_country: [Regions]? = nil
}

struct ProductionCountry: Codable {
    var iso_3166_1: Regions? = nil
    var name: String? = nil
}


struct MovieDetails: Codable {
    var id: Int = 0
    var adult: Bool = true
    var backdropPath: String? = nil
    var belongsToCollection: String? = nil
    var budget: Int = 0
    var genres: [Genres]? = nil
    var homepage: String? =  nil
    var imdbId: String? = nil
    var originalLanguage: String? = nil
    var originalTitle: String? = nil
    var overview: String? = nil
    var popularity: Double = 0.0
    var posterPath: String? = nil
    var productionCompanies: [ProductionCompany]? = nil
    var productionCountries: [ProductionCountry]? = nil
    var releaseDate: String? = nil
    var revenue: Int = 0
    var runtime: Int = 0
    var title: String? = nil
    var video: Bool = true
    var voteAverage: Double = 0.0
    var voteCount: Int = 0
}
