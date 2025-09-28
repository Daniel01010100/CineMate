//
//  MovieCards.swift
//  Cinemate
//
//  Created by YUDONG LU on 24/9/2025.
//

import SwiftUI

struct MovieCards: View {
    var cmvm: CineMateViewModel
    var movie: MovieBasics

    var body: some View {
        HStack {
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
            VStack(alignment: .leading) {
                Text(movie.title ?? "")
                    .bold()
                    .font(.headline)
                Text("Rating: \(movie.voteAverage ?? 0.0, specifier: "%.1f") (\(movie.voteCount ?? 0)) votes")
                Text("Release Date: \(movie.releaseDate ?? "")")
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
