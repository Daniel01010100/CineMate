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
        for _ in 0..<10 {
            // Create 10 new favorite station objects using KVC to avoid Movie symbol conflict
            let newItem = NSEntityDescription.insertNewObject(forEntityName: "Movie", into: viewContext)
            newItem.setValue(Date(), forKey: "addtime") // Set the add time to the current date
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
    }
    
    func saveNowPlayingMoviesToCoreData(_ movies: [MovieBasics]) {
        let context = container.viewContext

        // Remove previous entries
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = Movie.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
        } catch {
            print("Failed to clear existing movies: \(error)")
        }

        // Save new movies
        for movie in movies {
            let entity = Movie(context: context)
            entity.id = Int64(movie.id)
            entity.adult = movie.adult
            entity.backdropPath = movie.backdropPath ?? ""
            entity.originalLanguage = movie.originalLanguage ?? ""
            entity.originalTitle = movie.originalTitle ?? ""
            entity.overview = movie.overview ?? ""
            entity.popularity = movie.popularity ?? 0
            entity.posterPath = movie.posterPath ?? ""
            entity.releaseDate = movie.releaseDate ?? ""
            entity.title = movie.title ?? ""
            entity.voteAverage = movie.voteAverage ?? 0.0
            entity.voteCount = Int64(movie.voteCount ?? 0)
            
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

        do {
            try context.save()
        } catch {
            print("Failed to save movies: \(error)")
        }
    }
    
    func loadNowPlayingMoviesFromCoreData() throws -> [MovieBasics] {
        let context = container.viewContext
        let fetchRequest: NSFetchRequest<Movie> = Movie.fetchRequest()
        
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
                
                if let genres = entity.genre as? Set<Genre> {
                    basics.genreIds = genres.map { Int($0.id) }
                }
                return basics
            }
            return movies
        } catch {
            throw error
        }
    }
}
