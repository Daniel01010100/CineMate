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
                }
                .padding()

                List(cmvm.movies.prefix(_displayedMoviesAmont), id: \.id) { movie in
                    NavigationLink {
                        MovieDetailsView(movieId: movie.id, language: _language,  cmvm: cmvm)
                    } label: {
                        MovieCards(cmvm: cmvm, movie: movie)
                            .contentShape(Rectangle())
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
                    
                    Picker("Movies per page", selection: $_displayedMoviesAmont) {
                        ForEach(1...20, id: \.self) { amount in
                            HStack(spacing: 5) {
                                Text("\(amount)")
                                Text(amount == 1 ? "movie" : "movies")
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
    }
    
    private func performSearch() {
        Task {
            let year = self._didPickReleaseYear ? String(self._releasedYear) : ""
            await self.cmvm.searchMovies(_query, _adult, _language, year, _region)
        }
    }
}

#Preview {
    NavigationStack {
        MoviesView(cmvm: CineMateViewModel())
    }
}
