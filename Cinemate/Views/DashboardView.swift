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
        VStack(alignment: .leading, spacing: 10) {
            Text("Your Watchlist")
                .font(.title2)
                .bold()
                .frame(maxWidth: .infinity)
                .padding(.top, -60)
            
            ScrollView(.horizontal) {
                HStack(spacing: 15) {
                    ForEach(self.cmvm.watchlistMovies, id: \.id) { movie in
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
                                .frame(width: 120)
                                .multilineTextAlignment(.center)
                                .lineLimit(2)
                        }
                    }
                    .padding(.horizontal)
                }
            }
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
