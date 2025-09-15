//
//  APIManager.swift
//  Cinemate
//
//  Created by YUDONG LU on 15/9/2025.
//

import Foundation

protocol APIManagerProtocol {
    /*
     @Brief
        Obtain a list of movies that ordered by popularity.
     @Param
        language:   Defaults to en-US
     */
    func fetchPopularMovies(_ language: String, _ page: Int32, _ region: String) -> MovieInfo
    
    func searchMovies(_ query: String, _ includeAdult: Bool, _ language: String, _ primaryReleaseYear: Int32, _ page: Int32,
                     _ region: String, _ year: String) -> MovieInfo
    
    func fetchCurrentPlayingMovies(_ language: String, _ page: Int32, _ region: String) -> MovieInfo
    
    func fetchUpcomingMovies(_ language: String, _ page: Int32, _ region: String) -> MovieInfo
}
