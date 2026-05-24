//
//  DashboardView.swift
//  Cinemate
//
//  Created by YUDONG LU on 18/9/2025.
//

import SwiftUI

struct DashboardView: View {
    var cmvm: CineMateViewModel
    
    @State private var movieToDelete: MovieBasics?
    @State private var isConfirmingWatchlistDelete = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 28) {
                header
                watchlistSection
                latestRecordSection
                favouriteRecordsSection
            }
            .padding(.vertical, 22)
        }
        .background(Color(.systemBackground))
        .confirmationDialog(
            "Remove from watchlist?",
            isPresented: $isConfirmingWatchlistDelete,
            titleVisibility: .visible
        ) {
            Button("Remove", role: .destructive) {
                if let movieToDelete {
                    cmvm.removeMovieFromWatchlist(movieToDelete)
                }
                movieToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                movieToDelete = nil
            }
        }
        .onAppear {
            Task {
                cmvm.loadMovieRecords()
                await cmvm.loadMoviesDataIfNeeded()
            }
        }
    }
    
    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(cmvm.user.username.isEmpty ? "Welcome to Cinemate" : "Welcome back, \(cmvm.user.username)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(cmvm.cinemateColor)
            
            Text("Track what you plan to watch, rate what you just watched, and revisit the memories worth keeping.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 10) {
                miniStat(value: "\(cmvm.watchlistMovies.count)", label: "Watchlist")
                miniStat(value: "\(cmvm.movieRecords.count)", label: "Records")
                miniStat(value: "\(cmvm.getFavouriteRecords().count)", label: "Saved")
            }
            .padding(.top, 6)
        }
        .padding(.horizontal)
    }
    
    private var watchlistSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Watchlist", subtitle: "Movies you want to catch next")
            
            if cmvm.watchlistMovies.isEmpty {
                emptyState(
                    icon: "bookmark",
                    title: "No watchlist yet",
                    message: "Double tap a movie in Movies to save it here."
                )
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(cmvm.watchlistMovies, id: \.id) { movie in
                            watchlistCard(movie)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
    
    private var latestRecordSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Recently Watched", subtitle: "Rate the latest memory")
            
            if let record = cmvm.latestWatchedRecord {
                HStack(spacing: 14) {
                    posterImage(record.posterURL, width: 100, height: 150)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            Text(record.movieTitle ?? "Untitled")
                                .font(.headline)
                                .lineLimit(2)
                            
                            Spacer()
                            
                            Button {
                                cmvm.toggleRecordFavourite(record.id)
                            } label: {
                                Image(systemName: record.isFavourite ? "heart.fill" : "heart")
                                    .foregroundStyle(.red)
                            }
                        }
                        
                        Text(record.watchedDateText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        Text(record.companionText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        
                        ratingControl(for: record)
                    }
                }
                .padding(14)
                .background(cmvm.cinemateColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .padding(.horizontal)
            } else {
                emptyState(
                    icon: "film",
                    title: "No watched movies yet",
                    message: "Create a record from a movie detail page and it will appear here."
                )
            }
        }
    }
    
    private var favouriteRecordsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("Favourite Memories", subtitle: "Records you marked with a heart")
            
            let favouriteRecords = cmvm.getFavouriteRecords()
            if favouriteRecords.isEmpty {
                emptyState(
                    icon: "heart",
                    title: "No favourites yet",
                    message: "Tap the heart on a record to keep it in this section."
                )
            } else {
                FavouriteRecordsView(favouriteRecords: favouriteRecords, cmvmColour: cmvm.cinemateColor)
            }
        }
    }
    
    private func watchlistCard(_ movie: MovieBasics) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topTrailing) {
                posterImage(movie.posterURL, width: 120, height: 180)
                
                Button {
                    movieToDelete = movie
                    isConfirmingWatchlistDelete = true
                } label: {
                    Image(systemName: "trash.fill")
                        .font(.caption)
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(.black.opacity(0.68))
                        .clipShape(Circle())
                }
                .padding(6)
            }
            .contextMenu {
                Button(role: .destructive) {
                    movieToDelete = movie
                    isConfirmingWatchlistDelete = true
                } label: {
                    Label("Remove from Watchlist", systemImage: "trash")
                }
            }
            
            Text(movie.title ?? "Untitled")
                .font(.caption)
                .fontWeight(.medium)
                .lineLimit(2)
                .frame(width: 116, alignment: .leading)
        }
        .padding(12)
        .frame(width: 145, alignment: .leading)
        .background(cmvm.cinemateColor.opacity(0.15))
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(
            color: cmvm.cinemateColor.opacity(0.12), radius: 8, x: 0, y: 4)
    }
    
    private func ratingControl(for record: MovieRecords) -> some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { star in
                Button {
                    cmvm.updateRecordRating(record.id, rating: Double(star))
                } label: {
                    Image(systemName: star <= Int(record.userRating ?? 0) ? "star.fill" : "star")
                        .foregroundStyle(.yellow)
                }
                .buttonStyle(.plain)
            }
            
            Text(record.ratingText)
                .font(.caption)
                .foregroundStyle(.secondary)
                .padding(.leading, 4)
        }
    }
    
    private func posterImage(_ url: URL?, width: CGFloat, height: CGFloat) -> some View {
        AsyncImage(url: url) { phase in
            switch phase {
            case .empty:
                ZStack {
                    Color(.tertiarySystemFill)
                    ProgressView()
                }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                ZStack {
                    Color(.tertiarySystemFill)
                    Image(systemName: "photo")
                        .foregroundStyle(.secondary)
                }
            @unknown default:
                EmptyView()
            }
        }
        .frame(width: width, height: height)
        .clipped()
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    
    private func sectionHeader(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.title3)
                .fontWeight(.bold)
            Text(subtitle)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.horizontal)
    }
    
    private func miniStat(value: String, label: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.headline)
                .fontWeight(.bold)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: cmvm.cinemateColor.opacity(0.5), radius: 6, x: 0, y: 3)
    }
    
    private func emptyState(icon: String, title: String, message: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(cmvm.cinemateColor)
                .frame(width: 34, height: 34)
                .background(cmvm.cinemateColor.opacity(0.12))
                .clipShape(Circle())
            
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(message)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .padding(.horizontal)
    }
}

#Preview {
    DashboardView(cmvm: CineMateViewModel())
}
