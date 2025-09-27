//
//  CineMateViewModel.swift
//  Cinemate
//
//  Created by YUDONG LU on 15/9/2025.
//

import Foundation
import SwiftUI
import Observation

@Observable
final class CineMateViewModel {
    var user: UserProfile = .init()
    var apiManager: APIManager = .init()
    var movies: [MovieBasics] = []
    var movieDetails: MovieDetails? = nil
    var cinemateColor = Color(red: 25/255, green: 25/255, blue: 112/255)
    private let _persistence = PersistenceController.shared
    
    /**
     Determine whether the "Now playing" movies data should be updated.
     
     - Returns:
        true - If the last updated date is earlier than today (Outdated).
        false - If the last updated date is today (Up-to-date).
     */
    func shouldUpdateNowPlayingMovies() -> Bool {
        let lastFet = "lastFetchDate"
        let calendar = Calendar.current
        let now = calendar.startOfDay(for: Date())
        
        if let lastFetchDate = UserDefaults.standard.object(forKey: lastFet) as? Date {
            let lastDay = calendar.startOfDay(for: lastFetchDate)
            if now == lastDay {
                return false    // Already updated to the latest data.
            }
        }
        
        UserDefaults.standard.set(Date(), forKey: lastFet)
        return true
    }
    
    /**
     Update the "Now playing" movies data. If it's already up-to-date, then loaded from Core Data. Otherwise, it would be fetched from the API.
     */
    func loadNowPlayingIfNeeded() async {
        guard shouldUpdateNowPlayingMovies() else {
            do {
                self.movies = try self._persistence.loadNowPlayingMoviesFromCoreData()
            } catch {
                print("Failed to load movies from CoreData: \(error)")
            }
            return
        }
        
        await fetchNowPlayingMovies()
        self._persistence.saveNowPlayingMoviesToCoreData(self.movies)
    }
    
    /**
     Fetch the "Now playing" movies data from the remote API.
     
     - Parameters:
        language: An optional parameter of Languages structure, default to the user region setting.
        page: The page of the result returned by API, defaults to 1.
        region: An optional parameter of Regions structure, default to the user language setting.
     */
    func fetchNowPlayingMovies(_ language: Languages? = nil, _ page: Int32 = 1,_ region: Regions? = nil) async {
        let lang = language ?? user.preferredLanguage
        let reg = region ?? user.currentRegion
        do {
            let nowPlayingMovies = try await apiManager.fetchCurrentPlayingMovies(lang, page, reg)
            self.movies = nowPlayingMovies.results ?? []
        } catch {
            print("Error fetching now playing movies: \(error)")
        }
    }
    
    /**
     Fetch the "Upcoming" movies data from the remote API.
     
     - Parameters:
         language: An optional parameter of Languages structure, default to the user region setting.
         page: The page of the result returned by API, defaults to 1.
         region: An optional parameter of Regions structure, default to the user language setting.
     */
    func fetchUpcomingMovies(_ language: Languages? = nil, _ page: Int32 = 1,_ region: Regions? = nil) async {
        let lang = language ?? user.preferredLanguage
        let reg = region ?? user.currentRegion
        do {
            let upcomingMovies = try await apiManager.fetchUpcomingMovies(lang, page, reg)
            self.movies = upcomingMovies.results ?? []
        } catch {
            print("Error fetching upcoming movies: \(error)")
        }
    }
    
    /**
     Get search results from the API based on the query.
     
     - Parameters:
        query: The keywords to inquiry
        includeAdult: Whether to include the adult contents in the search results.
        language: An optional parameter of Languages structure, default to the user region setting.
        primaryReleaseYear: The movie's first release year
        region: An optional parameter of Regions structure, default to the user language setting.
     */
    func searchMovies(_ query: String, _ includeAdult: Bool = false, _ language: Languages? = nil,
                      _ primaryReleaseYear: String? = nil, _ region: Regions? = nil) async {
        let releaseYear = primaryReleaseYear ?? ""
        let lang = language ?? self.user.preferredLanguage
        let reg = region ?? self.user.currentRegion
        do {
            let movies = try await apiManager.searchMovies(query, includeAdult, lang, releaseYear, 1, reg, "")
            self.movies = movies.results ?? []
        } catch {
            print("Error fetching search results: \(error)")
        }
    }
    
    func getMovieDetails(_ movieId: Int, _ language: Languages = .English) async {
        do {
            self.movieDetails = try await apiManager.fetchMovieDetails(Int32(movieId), "", language)
        } catch {
            print("Error fetching movie details: \(error)")
        }
    }
    
    func updateUserPreferredLanguage(_ language: Languages) {
        user.preferredLanguage = language
    }
    
    func updateUserCurrentRegion(_ region: Regions) {
        user.currentRegion = region
    }
    
    func addMovieToUserWatchList(_ movieId: Int32) {
        if self.user.watchlist.contains(movieId) {
            return
        }
        self.user.watchlist.append(movieId)
    }
    
    func delMovieFromUserWatchList(_ movieId: Int32) -> Bool {
        if self.user.watchlist.firstIndex(of: movieId) == nil {
            return false
        }
        self.user.watchlist.removeAll { $0 == movieId }
        return true
    }
}
