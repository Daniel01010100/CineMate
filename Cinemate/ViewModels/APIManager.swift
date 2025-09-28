//
//  APIManager.swift
//  Cinemate
//
//  Created by YUDONG LU on 15/9/2025.
//

import Foundation

protocol APIManagerProtocol {
    func fetchPopularMovies(_ language: Languages, _ page: Int32, _ region: Regions) async throws -> MovieInfo
    
    func searchMovies(_ query: String, _ includeAdult: Bool, _ language: Languages, _ primaryReleaseYear: String, _ page: Int32,
                     _ region: Regions, _ year: String) async throws -> MovieInfo
    
    func fetchCurrentPlayingMovies(_ language: Languages, _ page: Int32, _ region: Regions) async throws -> MovieInfo
    
    func fetchUpcomingMovies(_ language: Languages, _ page: Int32, _ region: Regions) async throws -> MovieInfo
    
    func fetchMovieDetails(_ movieId: Int32, _ appendToResponse: String, _ language: Languages) async throws -> MovieDetails
}

class APIManager : APIManagerProtocol {
    private var defaultHeaders: [String: String] {
        [
            "accept": "application/json",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhNWM0YzYwZWE0MTFmNTUwMzE1M2ZjNTBmNjJhMmY5MCIsIm5iZiI6MTc1NzgzMjg2My4zNjcsInN1YiI6IjY4YzY2NjlmMmU0NmM3MTVlZjg2ODI1NiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.d7LLdR_CqKLlby4iaEQHYKG5_U8AEaAcrDlN_xXny30"
        ]
    }
    
    /**
     Obtain a list of movies that ordered by popularity.
     
     - Parameters:
        language (Languages):   Defaults to en-US.
        page (Int32):       Default to 1, the page of results.
        region (Regions):     The ISO-3166-1 code that represent region.
     */
    func fetchPopularMovies(_ language: Languages = .English, _ page: Int32 = 1, _ region: Regions) async throws -> MovieInfo {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/popular") else {
            throw URLError(.badURL)
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "language", value: language.rawValue),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "region", value: region.rawValue)
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = defaultHeaders

        let (data, _) = try await URLSession.shared.data(for: request)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let popularMovie = try jsonDecoder.decode(MovieInfo.self, from: data)
        
        return popularMovie
    }
    
    /**
     Search movies for query and obtain a list of movies.
     
     - Parameters:
        query (String):     The keyword for movie-searching function.
        includeAdult (Bool):    Whether to returns the movies for adults.
        language (Languages):      Defaults to en-US.
        primaryReleaseYear (String):  The release year of the movie.
        page (Int32):       Default to 1, the page of results.
        region (Regions):     The ISO-3166-1 code that represent region.
        year (String):
     */
    func searchMovies(_ query: String, _ includeAdult: Bool = false, _ language: Languages = .English,
                      _ primaryReleaseYear: String, _ page: Int32, _ region: Regions, _ year: String = "") async throws -> MovieInfo {
        guard let url = URL(string: "https://api.themoviedb.org/3/search/movie") else {
            throw URLError(.badURL)
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "include_adult", value: includeAdult ? "true" : "false"),
            URLQueryItem(name: "language", value: language.rawValue),
            URLQueryItem(name: "primary_release_year", value: primaryReleaseYear),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "region", value: region.rawValue),
            URLQueryItem(name: "year", value: year)
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = defaultHeaders

        let (data, _) = try await URLSession.shared.data(for: request)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let searchResult = try jsonDecoder.decode(MovieInfo.self, from: data)
        
        return searchResult
    }
    
    /**
     Obtain a list of now playing movies.
     - Parameters:
        language (Languages):   Defaults to en-US.
        page (Int32):       Default to 1, the page of results.
        region (Regions):     The ISO-3166-1 code that represent region.
     */
    func fetchCurrentPlayingMovies(_ language: Languages = .English, _ page: Int32,
                                   _ region: Regions) async throws -> MovieInfo {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing") else {
            throw URLError(.badURL)
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "language", value: language.rawValue),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "region", value: region.rawValue)
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = defaultHeaders

        let (data, _) = try await URLSession.shared.data(for: request)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let playingMovies = try jsonDecoder.decode(MovieInfo.self, from: data)
        
        return playingMovies
    }
    
    /**
     Obtain a list of upcoming movies.
     
     - Parameters:
        language (Languages):   Defaults to en-US.
        page (Int32):       Default to 1, the page of results.
        region (Regions):     The ISO-3166-1 code that represent region.
     */
    func fetchUpcomingMovies(_ language: Languages = .English, _ page: Int32, _ region: Regions) async throws -> MovieInfo {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/upcoming") else {
            throw URLError(.badURL)
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "language", value: language.rawValue),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "region", value: region.rawValue)
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = defaultHeaders

        let (data, _) = try await URLSession.shared.data(for: request)
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let upComingMovies = try jsonDecoder.decode(MovieInfo.self, from: data)
        print(upComingMovies)
        return upComingMovies
    }
    
    /**
     Obtain the detail of selected movie.
     
     - Parameters:
        movieId (Int32):    The id of selected movie.
        appendToResponse(String):   Which part of movie info should be appended.
        language (Languages):   Defaults to en-US.
     */
    func fetchMovieDetails(_ movieId: Int32, _ appendToResponse: String = "",
                           _ language: Languages = .English) async throws -> MovieDetails {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/\(movieId)") else {
            throw URLError(.badURL)
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "append_to_response", value: appendToResponse),
            URLQueryItem(name: "language", value: language.rawValue),
        ]
        components.queryItems = components.queryItems.map { $0 + queryItems } ?? queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = defaultHeaders

        let (data, _) = try await URLSession.shared.data(for: request)
        print(String(decoding: data, as: UTF8.self))
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        let movieDetails = try jsonDecoder.decode(MovieDetails.self, from: data)
        
        return movieDetails
    }
}
