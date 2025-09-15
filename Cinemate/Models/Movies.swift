//
//  Movies.swift
//  Cinemate
//
//  Created by YUDONG LU on 14/9/2025.
//

import Foundation

struct Movie: Codable {
    var id: Int = 0
    var adult: Bool = true
    var backdrop_path: String? = nil
    var genre_ids: [Int]? = nil
    var original_language: String? = nil
    var original_title: String? = nil
    var overview: String? = nil
    var popularity: Double = 0.0
    var poster_path: String? = nil
    var release_date: String? = nil
    var title: String? = nil
    var video: Bool = true
    var vote_average: Double = 0.0
    var vote_count: Int = 0
}

struct MovieDetails: Codable {
    var id: Int = 0
    var adult: Bool = true
    var backdrop_path: String? = nil
    var belongs_to_collection: String? = nil
    var budget: Int = 0
    var genres: [Genre]? = nil
    var homepage: String? =  nil
    var imdb_id: String? = nil
    var original_language: String? = nil
    var original_title: String? = nil
    var overview: String? = nil
    var popularity: Double = 0.0
    var poster_path: String? = nil
    var production_companies: [ProductionCompany]? = nil
    var production_countries: [ProductionCountry]? = nil
    var release_date: String? = nil
    var revenue: Int = 0
    var runtime: Int = 0
    var title: String? = nil
    var video: Bool = true
    var vote_average: Double = 0.0
    var vote_count: Int = 0
}

struct MovieInfo: Codable {
    var dates: Dates? = nil
    var page: Int = 0
    var results: [Movie]? = nil
    var total_pages: Int = 0
    var total_results: Int = 0
}

struct Dates: Codable {
    var maximum: String?
    var minimum: String?
}

struct Genre: Codable {
    var id: Int = 0
    var name: String? = nil
}

struct ProductionCompany: Codable {
    var id: Int = 0
    var logo_path: String? = nil
    var name: String? = nil
    var origin_country: [String]? = nil
}

struct ProductionCountry: Codable {
    var iso_3166_1: String? = nil
    var name: String? = nil
}
