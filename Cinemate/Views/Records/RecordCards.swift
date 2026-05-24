//
//  RecordCards.swift
//  Cinemate
//
//  Created by YUDONG LU on 2/10/2025.
//

import SwiftUI

struct RecordCards: View {
    let record: MovieRecords
    var onFavouriteToggle: (() -> Void)? = nil
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Button(action: {
                onFavouriteToggle?()
            }) {
                Image(systemName: record.isFavourite ? "heart.fill" : "heart")
                    .font(.title3)
                    .foregroundColor(.red)
            }
            
            AsyncImage(url: URL(string: "https://image.tmdb.org/t/p/w500\(record.moviePosterURLSnapshot ?? "")")) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(10)
                case .failure:
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(.secondary)

                @unknown default:
                    EmptyView()
                }
            }
            .frame(width: 100, height: 150)
            
            VStack(alignment: .leading) {
                Text(record.movieTitle ?? "")
                    .bold()  
                    .font(.headline)
                if let date = record.dateWatched {
                    let year = Calendar.current.component(.year, from: date)
                    let month = Calendar.current.component(.month, from: date)
                    
                    Text("Watched in \(DateFormatter().monthSymbols[month - 1].prefix(3)) \(year)")
                        .font(.subheadline)
                }
                
                VStack {
                    if !record.companions.isEmpty {
                        ForEach(record.companions, id: \.self) { companion in
                            Text("\(companion.name ?? "") (\(companion.relationship ?? ""))")
                                .font(.headline)
                        }
                    }
                }
                
                Text(record.viewingFormat[0].rawValue)
                    .font(.headline)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 10)
    }
}

