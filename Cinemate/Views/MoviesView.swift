//
//  MoviesView.swift
//  Cinemate
//
//  Created by YUDONG LU on 18/9/2025.
//

import SwiftUI

struct MoviesView: View {
    var cmvm: CineMateViewModel
    @State private var _query: String = ""
    @State private var _adult: Bool = false
    @State private var _region: Regions = .Australia
    @State private var _language: Languages = .English
    @State private var _releasedYear: Int = Calendar.current.component(.year, from: Date())
    @State private var _didPickReleaseYear: Bool = false
    @State private var _displayedMoviesAmont: Int = 5
    @State private var _isUpComing: Bool = false
    @State private var _showingFilters = false
    @State private var _showingHelp = false
    @State private var _watchlistStatus: Int = 0
    
    let movieYearRange: [Int] = Array((1900...Calendar.current.component(.year, from: Date())).reversed())
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search Bar + Filter Button
                HStack(spacing: 10) {
                    TextField("Search movies or keywords...", text: $_query)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .autocapitalization(.none)

                    Button(action: performSearch) {
                        Image(systemName: "magnifyingglass")
                    }

                    Button(action: { _showingFilters.toggle() }) {
                        Image(systemName: "slider.horizontal.3")
                    }
                    
                    Button(action: { _showingHelp.toggle() }) {
                        Image(systemName: "questionmark.circle")
                    }
                    .popover(isPresented: $_showingHelp) {
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Tips")
                                .font(.headline)
                            Text("* Double tap to add a movie to watchlist, long press to remove")
                                .font(.subheadline)
                            Text("* Turn on the \"Show upcoming movies\" switch to see upcoming releases")
                                .font(.subheadline)
                        }
                        .frame(width: 250)
                    }
                }
                .padding()

                // Inline title banner just below search bar
                Text(self.displayTitle)
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 5)
                .background(Color.gray.opacity(0.10))
                .foregroundColor(.secondary)
                
                List(cmvm.movies.prefix(_displayedMoviesAmont), id: \.id) { movie in
                    NavigationLink {
                        MovieDetailsView(movieId: movie.id, language: _language,  cmvm: cmvm)
                    } label: {
                        MovieCards(cmvm: cmvm, movie: movie)
                            .contentShape(Rectangle())
                            .onTapGesture(count: 2) {
                                self.cmvm.addMovieToUserWatchlist(movie)
                                self._watchlistStatus = 1
                                self.popUpDelay()
                            }
                            .onLongPressGesture {
                                let status = self.cmvm.delMovieFromUserWatchlist(movie)
                                if status {
                                    self._watchlistStatus = 2
                                    self.popUpDelay()
                                } else {
                                    self._watchlistStatus = 3
                                    self.popUpDelay()
                                }
                            }
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
                .listRowBackground(Color.clear)
            }
            .sheet(isPresented: $_showingFilters) {
                Form {
                    Toggle("Include Adult Content", isOn: $_adult)

                    Picker("Language", selection: $_language) {
                        ForEach(Languages.allCases) {
                            Text($0.label).tag($0)
                        }
                    }

                    Picker("Region", selection: $_region) {
                        ForEach(Regions.allCases, id: \.self) { region in
                            HStack {
                                Text("\(region.convertISOToNationalFlag()) \(region.rawValue)")
                            }
                            .tag(region)
                        }
                    }

                    Picker("Release Year", selection: $_releasedYear) {
                        ForEach(movieYearRange, id: \.self) {
                            Text(String($0)).tag($0)
                        }
                    }
                    .onChange(of: self._releasedYear) {
                        self._didPickReleaseYear = true
                    }
                    
                    Picker("Movies per page", selection: $_displayedMoviesAmont) {
                        ForEach(1...20, id: \.self) { amount in
                            HStack(spacing: 5) {
                                Text("\(amount)")
                                Text(amount == 1 ? "movie" : "movies")
                            }
                        }
                    }

                    Toggle("Show upcoming movies", isOn: $_isUpComing)
                        .onChange(of: _isUpComing) {
                            Task {
                                if _isUpComing {
                                    cmvm.currentMode = .upcoming
                                    await cmvm.fetchUpcomingMovies(_language, 1, _region)
                                } else {
                                    cmvm.currentMode = .nowPlaying
                                    await cmvm.loadMoviesDataIfNeeded()
                                }
                            }
                        }
                    
                    Button("Done") {
                        self._showingFilters = false
                    }
                }
            }
        }
        .navigationTitle("Cinemate")
        .onAppear {
            Task {
                await cmvm.loadMoviesDataIfNeeded()
            }
        }
    }
    
    private func performSearch() {
        Task {
            // If the textfield is empty and the search button is tapped, turn back to display "Now Playing" movies.
            if _query.isEmpty {
                cmvm.currentMode = .nowPlaying
                await cmvm.loadMoviesDataIfNeeded()
            } else {
                let year = self._didPickReleaseYear ? String(self._releasedYear) : ""
                await cmvm.searchMovies(_query, _adult, _language, year, _region)
            }
        }
    }
    
    private func popUpDelay() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation {
                self._watchlistStatus = 0
            }
        }
    }
    
    private var displayTitle: String {
        if _watchlistStatus == 1 {
            return "Movie added to watchlist"
        } else if _watchlistStatus == 2 {
            return "Movie removed from watchlist"
        } else if _watchlistStatus == 3 {
            return "This movie isn't in your watchlist"
        } else {
            switch cmvm.currentMode {
            case .nowPlaying:
                return "Now Playing"
            case .upcoming:
                return "Upcoming"
            case .search(let query):
                return "Search Results for \"\(query)\""
            }
        }
    }
}

#Preview {
    NavigationStack {
        MoviesView(cmvm: CineMateViewModel())
    }
}
