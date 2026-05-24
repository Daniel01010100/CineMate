//
//  RecordsView.swift
//  Cinemate
//
//  Created by YUDONG LU on 18/9/2025.
//

import SwiftUI

struct RecordsView: View {
    var cmvm: CineMateViewModel
    @State private var _groupStyle: RecordGroupingStyle = .date
    
    var body: some View {
        VStack {
            Picker("Group By", selection: $_groupStyle) {
                ForEach(RecordGroupingStyle.allCases, id: \.self) { style in
                    Text(style.rawValue).tag(style)
                }
            }
            .pickerStyle(.segmented)
            .frame(alignment: .top)
            .padding(.horizontal)
            
            if (cmvm.movieRecords.isEmpty) {
                Text("You can create a record in the movie detail page.")
                    .foregroundColor(.secondary)
                    .font(.headline)
                    .multilineTextAlignment(.center)
                    .padding(.top)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 24) {
                        ForEach(groupRecords().sorted(by: { $0.key < $1.key }), id: \.key) { key, records in
                            VStack(alignment: .leading, spacing: 12) {
                                switch _groupStyle {
                                case .companionship:
                                    Text("With \(key)")
                                case .date:
                                    Text("In \(key)")
                                case .genre:
                                    Text("\(key)")
                                }
                                
                                ForEach(records) { record in
                                    RecordCards(
                                        record: record,
                                        onFavouriteToggle: {
                                            if let index = cmvm.movieRecords.firstIndex(where: { $0.id == record.id }) {
                                                cmvm.movieRecords[index].isFavourite.toggle()
                                                cmvm.saveMovieRecords()
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
            }
        }
    }
    
    private func groupRecords() -> [String: [MovieRecords]] {
        var dict: [String: [MovieRecords]] = [:]
        
        switch self._groupStyle {
        case .genre:
            for record in cmvm.movieRecords {
                for genre in record.movieGenres {
                    let name = genre.name ?? "Unknown"
                    var arr = dict[name] ?? []
                    arr.append(record)
                    dict[name] = arr
                }
            }
            return dict
        case .date:
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy"
            for record in cmvm.movieRecords {
                let year = record.dateWatched.map { formatter.string(from: $0) } ?? "Unknown"
                var arr = dict[year] ?? []
                arr.append(record)
                dict[year] = arr
            }
            return dict
        case .companionship:
            for record in cmvm.movieRecords {
                for companion in record.companions {
                    let name = companion.name ?? "Unknown"
                    var arr = dict[name] ?? []
                    arr.append(record)
                    dict[name] = arr
                }
            }
            return dict
        }
    }
}

enum RecordGroupingStyle: String, Identifiable, CaseIterable {
    case genre = "Genre"
    case date = "Year"
    case companionship = "Companionship"
    
    var id: String { rawValue }
}



#Preview {
    RecordsView(cmvm: CineMateViewModel())
}
