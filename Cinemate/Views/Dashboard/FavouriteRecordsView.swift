//
//  FavouriteRecordsView.swift
//  Cinemate
//
//  Created by YUDONG LU on 20/5/2026.
//

import SwiftUI

struct FavouriteRecordsView: View {
    var favouriteRecords: [MovieRecords]
    let cmvmColour: Color
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                ForEach(favouriteRecords) { record in
                    VStack(alignment: .leading, spacing: 8) {
                        AsyncImage(url: record.posterURL) { phase in
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
                        .frame(width: 124, height: 176)
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        Text(record.movieTitle ?? "Unknown Movie")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .lineLimit(2)
                            .frame(width: 124, alignment: .leading)
                        
                        Label(record.ratingText, systemImage: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                        
                        Text(record.companionText)
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    .padding(10)
                    .background(cmvmColour.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }
            .padding(.horizontal)
        }
    }
}
