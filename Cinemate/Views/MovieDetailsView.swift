//
//  MovieDetailsView.swift
//  Cinemate
//
//  Created by YUDONG LU on 27/9/2025.
//

import SwiftUI

struct MovieDetailsView: View {
    var movieId: Int
    var language: Languages
    var cmvm: CineMateViewModel
    @State private var details: MovieDetails? = nil
    
    var body: some View {
        ScrollView {
            if let detail = details {
                AsyncImage(url: detail.posterURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 250)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, minHeight: 250)
                            .clipped()
                    case .failure:
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, minHeight: 250)
                    @unknown default:
                        EmptyView()
                    }
                }
                
                Text(detail.title ?? "Unknown title")
                    .font(.largeTitle)
                    .bold()
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top)
                
                Divider()
                    .padding(.vertical)
                
                Grid(alignment: .leading, horizontalSpacing: 12, verticalSpacing: 6) {
                    GridRow {
                        Text("Rating: \(detail.voteAverage ?? 0.0, specifier: "%.1f")")
                        Text("Release date: \(detail.releaseDate ?? "Unknown")")
                    }
                    
                    GridRow {
                        if let duration = detail.runtime {
                            let hours = duration / 60
                            let minutes = duration % 60
                            Text("Duration: \(hours) h \(minutes) mins")
                                .frame(width: 120, alignment: .leading)
                        } else {
                            Text("No duration found")
                        }
                        Text("Original language: \(detail.originalLanguage ?? "")")
                            .frame(width: 120, alignment: .leading)
                    }
                    
                    GridRow {
                        Text("Budget: \(formatNumber(detail.budget ?? 0))")
                        Text("Revenue: \(formatNumber(detail.revenue ?? 0))")
                    }
                }
                .padding(.horizontal)
                
                Divider()
                    .padding(.vertical)
                
                HStack(spacing: 20) {
                    if let homepage = detail.homepage,
                       let url = URL(string: homepage) {
                        Link("Jump to homepage", destination: url)
                            .buttonStyle(.borderedProminent)
                            .tint(cmvm.cinemateColor)
                    }
                    
                    if let imdbId = detail.imdbId,
                       let url = URL(string: "https://www.imdb.com/title/\(imdbId)/") {
                        Link("Jump to IMDb", destination: url)
                            .buttonStyle(.borderedProminent)
                            .tint(cmvm.cinemateColor)
                    }
                }
                .padding(.horizontal)
                
                Text(detail.overview ?? "Empty overview")
                    .font(.body)
                    .multilineTextAlignment(.leading)
                    .padding(.top)
                    .padding(.horizontal)
            } else {
                Text("No specific details found")
            }
        }
        .onAppear {
            Task {
                await self.cmvm.getMovieDetails(self.movieId, self.language)
                details = self.cmvm.movieDetails
            }
        }
    }
    
    func formatNumber(_ num: Int) -> String {
        if num >= 1000000000 {
            return String(format: "%.1fB", Double(num / 1000000000))
        } else if num >= 1000000 {
            return String(format: "%.1fM", Double(num / 1000000))
        } else if num >= 1000 {
            return String(format: "%.1fK", Double(num / 1000))
        } else {
            return "\(num)"
        }
    }
}

#Preview {
    MovieDetailsView(movieId: 0, language: .English, cmvm: .init())
}
