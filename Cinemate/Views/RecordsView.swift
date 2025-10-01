//
//  RecordsView.swift
//  Cinemate
//
//  Created by YUDONG LU on 18/9/2025.
//

import SwiftUI

struct RecordsView: View {
    var cmvm: CineMateViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {

        }
    }
    
    private func performAddNewRecord() {
        
    }
}

struct GroupedRecords: View {
    let title: String
    let groups: [String: [MovieRecords]]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Hello, World!")
        }
    }
}

struct RecordCards: View {
    var record: MovieRecords
    
    var body: some View {
        VStack(alignment: .leading) {
            if let posterPath = record.moviePosterURLSnapshot {
                AsyncImage(url: URL(string: posterPath)) { phase in
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
            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.secondary)
                    .frame(width: 100, height: 150)
            }
            Text("\(record.movieTitle ?? "")")
        }
    }
}

#Preview {
    RecordsView(cmvm: CineMateViewModel())
}
