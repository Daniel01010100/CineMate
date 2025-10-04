//
//  DashboardView.swift
//  Cinemate
//
//  Created by YUDONG LU on 18/9/2025.
//

import SwiftUI

struct DashboardView: View {
    var cmvm: CineMateViewModel
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20)
            {
                if cmvm.user.username.isEmpty {
                    Text("Welcome to Cinemate!")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                        .foregroundColor(cmvm.cinemateColor)
                } else {
                    Text("Welcome back, \(cmvm.user.username).")
                        .font(.largeTitle)
                        .bold()
                        .padding(.horizontal)
                        .foregroundColor(cmvm.cinemateColor)
                }
                
                // Watchlist Section
                Text("Your Watchlist")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(cmvm.watchlistMovies, id: \.id) { movie in
                            VStack {
                                AsyncImage(url: movie.posterURL) { phase in
                                    switch phase {
                                    case .empty:
                                        ProgressView()
                                            .frame(width: 100, height: 150)
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 150)
                                    case .failure:
                                        Image(systemName: "photo")
                                            .resizable()
                                            .scaledToFit()
                                            .foregroundColor(.secondary)
                                            .frame(width: 100, height: 150)
                                    @unknown default:
                                        EmptyView()
                                    }
                                }
                                Text(movie.title ?? "")
                                    .font(.caption)
                                    .frame(width: 100)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(30)
                
                Text("Your Movie Records")
                    .font(.title2)
                    .bold()
                    .padding(.horizontal)
                // If no movie records, show friendly message
                if cmvm.movieRecords.isEmpty {
                    Spacer()
                        .frame(height: 100)
                    Text("Don't hesitate to record your movie memories!")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: 5) {
                        if let date = cmvm.getMostWatchedDate(),
                            let companion = cmvm.getMostFrequentCompanion() {
                            Text("The month you watched most movies: \(date)")
                                .font(.subheadline)
                                .bold()
                            Text("Companion most frequently watched with: \(companion)")
                                .font(.subheadline)
                                .bold()
                        } else {
                            Text("There are no movie records contains date or companion information")
                                .font(.subheadline)
                                .bold()
                        }
                    }
                }
            }
            .padding(.top)
        }
        .onAppear {
            Task {
                await cmvm.loadMoviesDataIfNeeded()
            }
        }
    }
}

#Preview {
    DashboardView(cmvm: CineMateViewModel())
}
