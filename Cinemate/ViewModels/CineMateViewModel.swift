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
    var cinemaSearchManager: CinemaSearchManager = .init()
    var currentMode: MovieListMode = .nowPlaying
    var movies: [MovieBasics] = []
    var watchlistMovies: [MovieBasics] = []
    var movieDetails: MovieDetails? = nil
    var movieRecords: [MovieRecords] = []
    var cinemas: [CinemaModel] = []
    var cinemateColor = Color(red: 30/255, green: 58/255, blue: 138/255)
    
    private let _persistence = PersistenceController.shared
    
    /**
     Determine whether the "Now playing" movies data should be updated.
     
     - Returns:
        true - If the last updated date is older than 6 hours (Outdated).
        false - If the last updated date is within 6 hours (Up-to-date).
     */
    func shouldUpdateMoviesData() -> Bool {
        let lastFet = "lastFetchDate"
        let ttl: TimeInterval = 6 * 3600    // refersh now playing movies and user's watchlist movies data per 6 hours.
        let now = Date()
        
        if let lastFetchDate = UserDefaults.standard.object(forKey: lastFet) as? Date {
            if now.timeIntervalSince(lastFetchDate) < ttl {
                return false    // Already updated to the latest data.
            }
        }
        
        UserDefaults.standard.set(now, forKey: lastFet)
        return true
    }
    
    /**
     Update the data of movies "Now Playing" and user's watchlist. If it's already up-to-date, then loaded from Core Data. Otherwise, it would be fetched from the API.
     */
    func loadMoviesDataIfNeeded() async {
        // Data of watchlist movie should be loaded from Core Data
        if shouldUpdateMoviesData() {
            // If movie's data is outdated
            await fetchWatchlistMovies()
            self._persistence.saveWatchlistMoviesToCoreData(self.watchlistMovies)
        } else {
            // If movie's data is already up-to-date
            self.watchlistMovies = self.getWatchlistMovies()
            self.loadMovieRecords()
        }

        switch currentMode {
        case .nowPlaying:
            if shouldUpdateMoviesData() {
                // If movie's data is outdated
                await fetchNowPlayingMovies()
                self._persistence.saveNowPlayingMoviesToCoreData(self.movies)
            } else {
                // If movie's data is already up-to-date
                do {
                    self.movies = try self._persistence.loadNowPlayingMoviesFromCoreData()
                } catch {
                    print("Failed to load now playing movies from CoreData: \(error)")
                }
            }
        default:
            break
        }
    }
    
    /**
     Get data of movies in the watchlist from the API.
     */
    func fetchWatchlistMovies() async {
        let savedList = self._persistence.loadWatchlistMoviesFromCoreData()
        var updatedList: [MovieBasics] = []
        
        for movie in savedList {
            do {
                let details = try await self.apiManager.fetchMovieDetails(Int32(movie.id))
                updatedList.append(MovieBasics(details))
            } catch {
                print("Error fetching movie details for \(movie.id): \(error)")
            }
        }
        self.watchlistMovies = updatedList
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
            let searchResults = try await apiManager.searchMovies(query, includeAdult, lang, releaseYear, 1, reg, "")
            self.movies = searchResults.results ?? []
        } catch {
            print("Error fetching search results: \(error)")
        }
        self.currentMode = .search(query: query)
    }
    
    func getMovieDetails(_ movieId: Int, _ language: Languages = .English) async {
        do {
            self.movieDetails = try await apiManager.fetchMovieDetails(Int32(movieId), "", language)
        } catch {
            print("Error fetching movie details: \(error)")
        }
    }
    
    func saveUserProfile() {
        self._persistence.saveUserProfileToCoreData(self.user)
    }
    
    func loadUserProfile() {
        if let userProfile = self._persistence.loadUserProfileFromCoreData() {
            self.user = userProfile
        }
    }
    
    func updateUsername(_ username: String) {
        user.username = username
        self.saveUserProfile()
    }
    
    func updateUserProfileAvatar(_ image: UIImage) {
        if let data = image.jpegData(compressionQuality: 0.8) {
            self.user.avatar = data
        }
    }
    
    func updateUserPreferredLanguage(_ language: Languages) {
        user.preferredLanguage = language
        self.saveUserProfile()
    }
    
    func updateUserCurrentRegion(_ region: Regions) {
        user.currentRegion = region
        self.saveUserProfile()
    }
    
    func addMovieToUserWatchlist(_ movie: MovieBasics) {
        self._persistence.addWatchlistMoviesToCoreData(movie)
    }
    
    func delMovieFromUserWatchlist(_ movie: MovieBasics) -> Bool {
       return self._persistence.deleteMovieFromWatchlist(movie.id)
    }
    
    func removeMovieFromWatchlist(_ movie: MovieBasics) {
        if self.delMovieFromUserWatchlist(movie) {
            self.watchlistMovies.removeAll { $0.id == movie.id }
        }
    }
    
    func getWatchlistMovies() -> [MovieBasics] {
        return self._persistence.loadWatchlistMoviesFromCoreData()
    }
    
    func addMovieRecord(_ movieId: Int, _ posterPath: String? = nil, _ title: String? = nil,
                        _ genres: [Genres] = [], _ cinemaId: UUID? = nil,
                        _ date: Date? = nil, _ format: [ViewingFormat] = [], _ rating: Double? = nil,
                        _ review: String? = nil, _ companions: [CompanionModel] = []) {
        let newRecord = MovieRecords(movieId, false, posterPath, title, genres, cinemaId,
                                     date, format, rating, review, companions)
        self.movieRecords.append(newRecord)
        self._persistence.addMovieRecordToCoreData(newRecord)
    }
    
    func delMovieRecord(_ recordId: UUID) -> Bool {
        self.movieRecords.removeAll { $0.id == recordId }
        return self._persistence.deleteMovieRecordFromCoreData(recordId)
    }
    
    func saveMovieRecords() {
        self._persistence.saveMovieRecordsToCoreData(self.movieRecords)
    }
    
    func loadMovieRecords() {
        self.movieRecords = self._persistence.loadMovieRecordsFromCoreData()
    }
    
    func getFavouriteRecords() -> [MovieRecords] {
        return self.movieRecords
            .filter { $0.isFavourite }
            .sorted { ($0.dateWatched ?? .distantPast) > ($1.dateWatched ?? .distantPast) }
    }
    
    var latestWatchedRecord: MovieRecords? {
        self.movieRecords
            .sorted { ($0.dateWatched ?? .distantPast) > ($1.dateWatched ?? .distantPast) }
            .first
    }
    
    func updateRecordRating(_ recordId: UUID, rating: Double) {
        guard let index = self.movieRecords.firstIndex(where: { $0.id == recordId }) else {
            return
        }
        self.movieRecords[index].userRating = rating
        self.saveMovieRecords()
    }
    
    func toggleRecordFavourite(_ recordId: UUID) {
        guard let index = self.movieRecords.firstIndex(where: { $0.id == recordId }) else {
            return
        }
        self.movieRecords[index].isFavourite.toggle()
        self.saveMovieRecords()
    }
    
    func addCinema(_ cinema: CinemaModel) {
        if !self.cinemas.contains(where: { $0.id == cinema.id }) {
            self.cinemas.append(cinema)
        }
    }
    
    /**
     Get cinema model based on the cinema's id
     
     - Parameters:
        cinemaId: UUID?
     */
    func getCinemaById(_ cinemaId: UUID?) -> CinemaModel? {
        guard let cId = cinemaId else {
            return nil
        }
        for cinema in cinemas {
            if cinema.id == cId {
                return cinema
            }
        }
        return nil
    }
    
    /**
     Get the date when user wathced most movies
     
     - Returns:
        String? A string that contains month and years components in the format of MM-yyyy
     */
    func getMostWatchedDate() -> String? {
        let calendar = Calendar.current
        var monthCounts: [String: Int] = [:]
        
        for record in self.movieRecords {
            if let date = record.dateWatched {
                let components = calendar.dateComponents([.year, .month], from: date)
                if let year = components.year, let month = components.month {
                    let key = String(format: "%02d/%04d", month, year)
                    monthCounts[key, default: 0] += 1
                }
            }
        }
        return monthCounts.max{ $0.value < $1.value }?.key
    }
    
    /**
     Get data of the companion who watched the most movies with user
     
     - Returns:
        String? A string that includs the companion's name
     */
    func getMostFrequentCompanion() -> String? {
        var companionCounts: [String: Int] = [:]
        
        for record in movieRecords {
            for companion in record.companions {
                let key = companion.name ?? ""
                companionCounts[key, default: 0] += 1
            }
        }
        return companionCounts.max{ $0.value < $1.value }?.key
    }
}

enum MovieListMode {
    case nowPlaying
    case upcoming
    case search(query: String)
}
