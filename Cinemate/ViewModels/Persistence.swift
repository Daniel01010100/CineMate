//
//  Persistence.swift
//  Cinemate
//
//  Created by YUDONG LU on 14/9/2025.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()
    
    // Preview instance using in-memory storage (e.g., for SwiftUI previews)
    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true) // Create an instance with in-memory storage
        let viewContext = result.container.viewContext // Get the view context from the container
        for i in 0..<10 {
            // Create 10 NowPlayingMovie preview objects
            let item = NowPlayingMovie(context: viewContext)
            item.id = Int64(i)
            item.title = "Preview #\(i)"
            item.releaseDate = "2025-01-0\((i % 9) + 1)"
            item.posterPath = nil
            item.backdropPath = nil
        }
        do {
            try viewContext.save() // Save the context to persist the new objects
        } catch {
            // Handle error if unable to save context
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result // Return the instance for preview
    }()

    let container: NSPersistentContainer // Main persistent container

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Cinemate") // Initialize container with the model name
        if inMemory {
            // Configure in-memory store
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            // Handle error during store loading
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true // Automatically merge changes from parent context
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    /**
     Save the fetched data of "Now Playing" movies into Core Data
     
     - Parameters
        movies - An array that stores all now playing movies.
     */
    func saveNowPlayingMoviesToCoreData(_ movies: [MovieBasics]) {
        let context = container.viewContext

        // Remove previous entries
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NowPlayingMovie.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        deleteRequest.resultType = .resultTypeObjectIDs
         do {
             if let result = try context.execute(deleteRequest) as? NSBatchDeleteResult,
                let objectIDs = result.result as? [NSManagedObjectID] {
                 let changes: [AnyHashable: Any] = [NSDeletedObjectsKey: objectIDs]
                 NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
             }
         } catch {
             print("Failed to clear existing movies in Core Data: \(error)")
         }

        // Save new movies
        for movie in movies {
            let entity = NowPlayingMovie(context: context)
            entity.id = Int64(movie.id)
            entity.adult = movie.adult
            entity.backdropPath = movie.backdropPath
            entity.originalLanguage = movie.originalLanguage ?? ""
            entity.originalTitle = movie.originalTitle ?? ""
            entity.overview = movie.overview ?? ""
            entity.popularity = movie.popularity ?? 0
            entity.posterPath = movie.posterPath
            entity.releaseDate = movie.releaseDate ?? ""
            entity.title = movie.title ?? ""
            entity.voteAverage = movie.voteAverage ?? 0.0
            entity.voteCount = Int64(movie.voteCount ?? 0)
            
            // Convert the array of genre id to the relationship genre
            if let genreIds = movie.genreIds {
                for gid in genreIds {
                    let fetch: NSFetchRequest<Genre> = Genre.fetchRequest()
                    fetch.predicate = NSPredicate(format: "id == %d", gid)
                    fetch.fetchLimit = 1

                    if let existing = try? context.fetch(fetch).first {
                        entity.addToGenre(existing)
                    } else {
                        let newGenre = Genre(context: context)
                        newGenre.id = Int64(gid)
                        entity.addToGenre(newGenre)
                    }
                }
            }
        }
        // Save data to the Core Data
        do {
            try context.save()
        } catch {
            print("Failed to save now playing movies to Core Data: \(error)")
        }
    }
    
    /**
     Load the data of "Now Playing" movies from the Core Data
     
     - Returns
        [MovieBasics]
     */
    func loadNowPlayingMoviesFromCoreData() throws -> [MovieBasics] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<NowPlayingMovie> = NowPlayingMovie.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "popularity", ascending: false),
            NSSortDescriptor(key: "title", ascending: true)
        ]
        
        do {
            let movieEntities = try context.fetch(fetchRequest)
            let movies: [MovieBasics] = movieEntities.map { entity in
                var basics = MovieBasics()
                basics.id = Int(entity.id)
                basics.adult = entity.adult
                basics.backdropPath = entity.backdropPath
                basics.originalLanguage = entity.originalLanguage
                basics.originalTitle = entity.originalTitle
                basics.overview = entity.overview
                basics.popularity = entity.popularity
                basics.posterPath = entity.posterPath
                basics.releaseDate = entity.releaseDate
                basics.title = entity.title
                basics.voteAverage = entity.voteAverage
                basics.voteCount = Int(entity.voteCount)
                
                // Convert the genre relationship to an array that stores genre id.
                if let genres = entity.genre as? Set<Genre> {
                    basics.genreIds = genres.map { Int($0.id) }.sorted()
                }
                return basics
            }
            return movies
        } catch {
            throw error
        }
    }
    

    func addWatchlistMoviesToCoreData(_ movie: MovieBasics) {
        let context = container.viewContext

        let fetch: NSFetchRequest<WatchlistMovie> = WatchlistMovie.fetchRequest()
        fetch.predicate = NSPredicate(format: "id == %d", movie.id)
        fetch.fetchLimit = 1

        let entity: WatchlistMovie
        if let existing = try? context.fetch(fetch).first {
            entity = existing
        } else {
            entity = WatchlistMovie(context: context)
            entity.id = Int64(movie.id)
        }

        // Update attributes fields
        entity.adult = movie.adult
        entity.backdropPath = movie.backdropPath
        entity.originalLanguage = movie.originalLanguage ?? ""
        entity.originalTitle = movie.originalTitle ?? ""
        entity.overview = movie.overview ?? ""
        entity.popularity = movie.popularity ?? 0
        entity.posterPath = movie.posterPath
        entity.releaseDate = movie.releaseDate ?? ""
        entity.title = movie.title ?? ""
        entity.voteAverage = movie.voteAverage ?? 0.0
        entity.voteCount = Int64(movie.voteCount ?? 0)

        if let genreIds = movie.genreIds {
            // Clear existing data
            if let existingGenres = entity.genre as? Set<Genre>, !existingGenres.isEmpty {
                existingGenres.forEach { entity.removeFromGenre($0) }
            }

            for gid in genreIds {
                let gf: NSFetchRequest<Genre> = Genre.fetchRequest()
                gf.predicate = NSPredicate(format: "id == %d", gid)
                gf.fetchLimit = 1
                if let found = try? context.fetch(gf).first {
                    entity.addToGenre(found)
                } else {
                    let newGenre = Genre(context: context)
                    newGenre.id = Int64(gid)
                    entity.addToGenre(newGenre)
                }
            }
        }
        // Save context
        do {
            try context.save()
        } catch {
            print("Failed to save watchlist movie to Core Data: \(error)")
        }
    }

    func deleteMovieFromWatchlist(_ id: Int) -> Bool {
        let context = container.viewContext
        let fetch: NSFetchRequest<WatchlistMovie> = WatchlistMovie.fetchRequest()
        fetch.predicate = NSPredicate(format: "id == %d", id)
        fetch.fetchLimit = 1

        do {
            if let target = try context.fetch(fetch).first {
                context.delete(target)
                try context.save()
            }
        } catch {
            print("Failed to delete watchlist movie from Core Data: \(error)")
            return false
        }
        return true
    }
    
    /**
     Save the data of movies in the watchinglist into the Core Data
     
     - Parameters
        movies - An array that stores all now playing movies.
     */
    func saveWatchlistMoviesToCoreData(_ movies: [MovieBasics]) {
        let context = container.viewContext
        
        for movie in movies {
            let fetch: NSFetchRequest<WatchlistMovie> = WatchlistMovie.fetchRequest()
            fetch.predicate = NSPredicate(format: "id == %d", movie.id)
            fetch.fetchLimit = 1
            
            let entity: WatchlistMovie
            if let existing = try? context.fetch(fetch).first {
                entity = existing
            } else {
                entity = WatchlistMovie(context: context)
                entity.id = Int64(movie.id)
            }
            
            // Update attributes
            entity.adult = movie.adult
            entity.backdropPath = movie.backdropPath
            entity.originalLanguage = movie.originalLanguage ?? ""
            entity.originalTitle = movie.originalTitle ?? ""
            entity.overview = movie.overview ?? ""
            entity.popularity = movie.popularity ?? 0
            entity.posterPath = movie.posterPath
            entity.releaseDate = movie.releaseDate ?? ""
            entity.title = movie.title ?? ""
            entity.voteAverage = movie.voteAverage ?? 0.0
            entity.voteCount = Int64(movie.voteCount ?? 0)
            
            // Sync genres
            if let genreIds = movie.genreIds {
                if let existingGenres = entity.genre as? Set<Genre>, !existingGenres.isEmpty {
                    existingGenres.forEach { entity.removeFromGenre($0) }
                }
                for gid in genreIds {
                    let gf: NSFetchRequest<Genre> = Genre.fetchRequest()
                    gf.predicate = NSPredicate(format: "id == %d", gid)
                    gf.fetchLimit = 1
                    if let found = try? context.fetch(gf).first {
                        entity.addToGenre(found)
                    } else {
                        let newGenre = Genre(context: context)
                        newGenre.id = Int64(gid)
                        entity.addToGenre(newGenre)
                    }
                }
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save watchlist movies to Core Data: \(error)")
        }
    }
    
    func loadWatchlistMoviesFromCoreData() -> [MovieBasics] {
        let context = container.viewContext
        let fetch: NSFetchRequest<WatchlistMovie> = WatchlistMovie.fetchRequest()
        fetch.sortDescriptors = [
            NSSortDescriptor(key: "title", ascending: true)
        ]

        do {
            let entities = try context.fetch(fetch)
            return entities.map { e in
                var basics = MovieBasics()
                basics.id = Int(e.id)
                basics.adult = e.adult
                basics.backdropPath = e.backdropPath
                basics.originalLanguage = e.originalLanguage
                basics.originalTitle = e.originalTitle
                basics.overview = e.overview
                basics.popularity = e.popularity
                basics.posterPath = e.posterPath
                basics.releaseDate = e.releaseDate
                basics.title = e.title
                basics.voteAverage = e.voteAverage
                basics.voteCount = Int(e.voteCount)
                if let genres = e.genre as? Set<Genre> {
                    basics.genreIds = genres.map { Int($0.id) }.sorted()
                }
                return basics
            }
        } catch {
            print("Failed to load watchlist from Core Data: \(error)")
            return []
        }
    }
    
    func addMovieRecordToCoreData(_ movieRecord: MovieRecords) {
        let context = container.viewContext

        let fetch: NSFetchRequest<Record> = Record.fetchRequest()
        fetch.predicate = NSPredicate(format: "id == %@", movieRecord.id as CVarArg)
        fetch.fetchLimit = 1

        let entity: Record
        if let existing = try? context.fetch(fetch).first {
            entity = existing
        } else {
            entity = Record(context: context)
            entity.id = movieRecord.id
        }

        // Update attributes fields
        entity.id = movieRecord.id
        entity.movieId = Int64(movieRecord.movieId)
        entity.moviePosterURLSnapshot = movieRecord.moviePosterURLSnapshot
        entity.movieTitle = movieRecord.movieTitle
        entity.cinemaId = movieRecord.cinemaId
        entity.dateWatched = movieRecord.dateWatched
        entity.viewingFormat = movieRecord.viewingFormat.map { $0.rawValue }.joined(separator: ",")
        entity.userRating = movieRecord.userRating ?? 0.0
        entity.review = movieRecord.review

        // Save context
        do {
            try context.save()
        } catch {
            print("Failed to save record to Core Data: \(error)")
        }
    }
    
    func deleteMovieRecordFromCoreData(_ recordId: UUID) -> Bool {
        let context = container.viewContext
        let fetch: NSFetchRequest<Record> = Record.fetchRequest()
        fetch.predicate = NSPredicate(format: "id == %@", recordId as CVarArg)
        fetch.fetchLimit = 1

        do {
            if let target = try context.fetch(fetch).first {
                context.delete(target)
                try context.save()
            }
        } catch {
            print("Failed to delete record from Core Data: \(error)")
            return false
        }
        return true
    }
    
    func saveMovieRecordsToCoreData(_ movieRecords: [MovieRecords]) {
        let context = container.viewContext
        
        for movieRecord in movieRecords {
            let fetch: NSFetchRequest<Record> = Record.fetchRequest()
            fetch.predicate = NSPredicate(format: "id == %@", movieRecord.id as CVarArg)
            fetch.fetchLimit = 1
            
            let entity: Record
            if let existing = try? context.fetch(fetch).first {
                entity = existing
            } else {
                entity = Record(context: context)
                entity.id = movieRecord.id
            }
            
            entity.id = movieRecord.id
            entity.movieId = Int64(movieRecord.movieId)
            entity.moviePosterURLSnapshot = movieRecord.moviePosterURLSnapshot
            entity.movieTitle = movieRecord.movieTitle
            entity.cinemaId = movieRecord.cinemaId
            entity.dateWatched = movieRecord.dateWatched
            entity.viewingFormat = movieRecord.viewingFormat.map { $0.rawValue }.joined(separator: ",")
            entity.userRating = movieRecord.userRating ?? 0.0
            entity.review = movieRecord.review

            // Clear existing companions if any
            if let existingCompanions = entity.companions as? Set<Companion> {
                for c in existingCompanions {
                    context.delete(c)
                }
            }

            // Add new companions
            for companion in movieRecord.companions {
                let c = Companion(context: context)
                c.name = companion.name
                c.relationship = companion.relationship
                c.userId = companion.userId
                c.isPrimary = companion.isPrimary
                entity.addToCompanions(c)
            }
        }
        
        do {
            try context.save()
        } catch {
            print("Failed to save movie records to Core Data: \(error)")
        }
    }
    
    func loadMovieRecordsFromCoreData() -> [MovieRecords] {
        let context = container.viewContext
        let fetch: NSFetchRequest<Record> = Record.fetchRequest()
        fetch.sortDescriptors = [NSSortDescriptor(key: "dateWatched", ascending: true)]
        
        do {
            let entities = try context.fetch(fetch)
            return entities.map{ e in
                var records = MovieRecords()
                records.id = e.id!
                records.movieId = Int(e.movieId)
                records.moviePosterURLSnapshot = e.moviePosterURLSnapshot
                records.movieTitle = e.movieTitle
                records.cinemaId = e.cinemaId
                records.dateWatched = e.dateWatched!
                records.viewingFormat = e.viewingFormat?.split(separator: ",").compactMap { ViewingFormat(rawValue: String($0)) } ?? []
                records.userRating = e.userRating
                records.review = e.review
                if let companionSet = e.companions as? Set<Companion> {
                    records.companions = companionSet.map { c in
                        CompanionModel(c.name, c.relationship, c.userId, c.isPrimary)
                    }
                }
                return records
            }
        } catch {
            print("Failed to load watchlist from Core Data: \(error)")
            return []
        }
    }
    
    func saveUserProfileToCoreData(_ userProfile: UserProfile) {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        let user: User
        if let fetchedUser = try? context.fetch(fetchRequest).first {
            user = fetchedUser
        } else {
            user = User(context: context)
            user.id = UUID()
        }
        
        user.currentRegion = userProfile.currentRegion.rawValue
        user.preferredLanguage = userProfile.preferredLanguage.rawValue
        
        do {
            try context.save()
        } catch {
            print("Failed to save user profile to Core Data: \(error)")
        }
    }
    
    func loadUserProfileFromCoreData() -> UserProfile? {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.fetchLimit = 1
                
        do {
            if let fetchedUser = try context.fetch(fetchRequest).first {
                var userProfile = UserProfile()
                userProfile.currentRegion = Regions(rawValue: fetchedUser.currentRegion ?? "AU") ?? .Australia
                userProfile.preferredLanguage = Languages(rawValue: fetchedUser.preferredLanguage ?? "en") ?? .English
                return userProfile
            }
        } catch {
            print("Failed to load user profile from Core Data: \(error)")
        }
        return nil
    }
}
