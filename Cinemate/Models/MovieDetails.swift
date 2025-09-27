//
//  MovieDetails.swift
//  Cinemate
//
//  Created by YUDONG LU on 27/9/2025.
//

import Foundation

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

struct BelongsToCollection: Codable {
    var id: Int? = nil
    var name: String? = nil
    var posterPath: String? = nil
    var backdropPath: String? = nil
}


struct MovieDetails: Codable {
    var id: Int = 0
    var adult: Bool = true
    var backdropPath: String? = nil
    var belongsToCollection: BelongsToCollection? = nil
    var budget: Int? = nil
    var genres: [Genres]? = nil
    var homepage: String? =  nil
    var imdbId: String? = nil
    var originalLanguage: String? = nil
    var originalTitle: String? = nil
    var overview: String? = nil
    var popularity: Double? = nil
    var posterPath: String? = nil
    var productionCompanies: [ProductionCompany]? = nil
    var productionCountries: [ProductionCountry]? = nil
    var releaseDate: String? = nil
    var revenue: Int? = nil
    var runtime: Int? = nil
    var title: String? = nil
    var video: Bool = false
    var voteAverage: Double? = nil
    var voteCount: Int? = nil
}
