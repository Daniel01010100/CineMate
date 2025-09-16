//
//  APIManager.swift
//  Cinemate
//
//  Created by YUDONG LU on 15/9/2025.
//

import Foundation

protocol APIManagerProtocol {
    func fetchPopularMovies(_ language: String, _ page: Int32, _ region: String) async throws -> MovieInfo
    
    func searchMovies(_ query: String, _ includeAdult: Bool, _ language: String, _ primaryReleaseYear: String, _ page: Int32,
                     _ region: String, _ year: String) async throws -> MovieInfo
    
    func fetchCurrentPlayingMovies(_ language: String, _ page: Int32, _ region: String) async throws -> MovieInfo
    
    func fetchUpcomingMovies(_ language: String, _ page: Int32, _ region: String) async throws -> MovieInfo
}

class APIManager : APIManagerProtocol {
    private var defaultHeaders: [String: String] {
        [
            "accept": "application/json",
            "Authorization": "Bearer eyJhbGciOiJIUzI1NiJ9.eyJhdWQiOiJhNWM0YzYwZWE0MTFmNTUwMzE1M2ZjNTBmNjJhMmY5MCIsIm5iZiI6MTc1NzgzMjg2My4zNjcsInN1YiI6IjY4YzY2NjlmMmU0NmM3MTVlZjg2ODI1NiIsInNjb3BlcyI6WyJhcGlfcmVhZCJdLCJ2ZXJzaW9uIjoxfQ.d7LLdR_CqKLlby4iaEQHYKG5_U8AEaAcrDlN_xXny30"
        ]
    }
    
    /*
     @Brief
        Obtain a list of movies that ordered by popularity.
     @Param
        language:   Defaults to en-US.
        page:       Default to 1, the page of results.
        region:     The ISO-3166-1 code that represent region.
     */
    func fetchPopularMovies(_ language: String = "en-US", _ page: Int32 = 1, _ region: String) async throws -> MovieInfo {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/popular") else {
            throw URLError(.badURL)
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "region", value: region)
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
    
    /*
     @Brief
        Obtain a list of movies that ordered by popularity.
     @Param
        language:   Defaults to en-US.
        page:       Default to 1, the page of results.
        region:     The ISO-3166-1 code that represent region.
     */
    func searchMovies(_ query: String, _ includeAdult: Bool = false, _ language: String = "en-US",
                      _ primaryReleaseYear: String, _ page: Int32, _ region: String, _ year: String) async throws -> MovieInfo {
        guard let url = URL(string: "https://api.themoviedb.org/3/search/movie") else {
            throw URLError(.badURL)
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "include_adult", value: includeAdult ? "true" : "false"),
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "primary_release_year", value: primaryReleaseYear),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "region", value: region),
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
    
    /*
     @Brief
        Obtain a list of movies that ordered by popularity.
     @Param
        language:   Defaults to en-US.
        page:       Default to 1, the page of results.
        region:     The ISO-3166-1 code that represent region.
     */
    func fetchCurrentPlayingMovies(_ language: String, _ page: Int32, _ region: String) async throws -> MovieInfo {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing") else {
            throw URLError(.badURL)
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "region", value: region)
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
    
    /*
     @Brief
        Obtain a list of movies that ordered by popularity.
     @Param
        language:   Defaults to en-US.
        page:       Default to 1, the page of results.
        region:     The ISO-3166-1 code that represent region.
     */
    func fetchUpcomingMovies(_ language: String, _ page: Int32, _ region: String) async throws -> MovieInfo {
        guard let url = URL(string: "https://api.themoviedb.org/3/movie/upcoming") else {
            throw URLError(.badURL)
        }
        var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
        let queryItems: [URLQueryItem] = [
            URLQueryItem(name: "language", value: language),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "region", value: region)
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
        
        return upComingMovies
    }
}
