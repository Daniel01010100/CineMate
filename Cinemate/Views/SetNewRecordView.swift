//
//  SetNewRecordView.swift
//  Cinemate
//
//  Created by YUDONG LU on 30/9/2025.
//

import SwiftUI
import MapKit

struct SetNewRecordView: View {
    var cmvm: CineMateViewModel
    var movieId: Int
    var posterPath: String
    var title: String
    @State private var _showingMap: Bool = false
    @State private var _cinema: CinemaModel? = nil
    @State private var _date: Date = Date()
    @State private var _format: [ViewingFormat] = []
    @State private var _rating: Double = 0.0
    @State private var _review: String = ""
    @State private var _name: String = ""
    @State private var _relationship: String = ""
    @State private var _companions: [CompanionModel] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Set New Record")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 16)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cinema")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button(action: {
                        self._showingMap.toggle()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "map")
                            Text(_cinema == nil ? "Select" : "Choosed Cinema: ")
                            if let cinema = _cinema {
                                Text("\(cinema.name)")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                    }
                }
                
                HStack(alignment: .center, spacing: 8) {
                    Text("Date Watched")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    DatePicker("Date", selection: $_date, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .padding(10)
                        .labelsHidden()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Viewing Format")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("Viewing Format", selection: $_format) {
                        ForEach(ViewingFormat.allCases, id: \.self) { format in
                            HStack {
                                Text(format.rawValue)
                            }
                            .tag(format)
                        }
                    }
                    .padding(10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rating")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Picker("", selection: $_rating) {
                        ForEach(1...10, id: \.self) { rating in
                            Text("\(rating)")
                                .tag(rating)
                        }
                    }
                    .pickerStyle(.menu)
                    .padding()
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Review")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Write your review", text: $_review)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .foregroundColor(.primary)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Companions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Companion's name", text: $_name)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .foregroundColor(.primary)
                    TextField("Your relationship with the companion", text: $_relationship)
                        .padding(10)
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .foregroundColor(.primary)
                }
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
            
            Button(action: {
                let companion = CompanionModel(_name, _relationship)
                _companions.append(companion)
                cmvm.addMovieRecord(movieId, posterPath, title, _cinema?.id, _date, _format, _rating, _review, _companions)
            }, label: {
                Text("Add")
                    .font(.headline)
                    .bold()
                    .tint(cmvm.cinemateColor)
            })
        }
        .sheet(isPresented: $_showingMap) {
            NearbyCinemaView(cmvm: cmvm, showingMap: $_showingMap, selectedCinema: $_cinema)
        }
    }
}

struct NearbyCinemaView: View {
    var cmvm: CineMateViewModel
    @State private var _keyword: String = ""
    @Binding var showingMap: Bool
    @Binding var selectedCinema: CinemaModel?
    
    var body: some View {
        VStack {
            TextField("Search cinemas", text: $_keyword)
                .textFieldStyle(.roundedBorder)
                .padding()
                .onChange(of: _keyword) {
                    cmvm.cinemaSearchManager.searchCinemasByKeyword(_keyword)
                }

            Map(position: .constant(.automatic)) {
                ForEach(cmvm.cinemaSearchManager.nearbyCinemas, id: \.self) { cinema in
                    if let coordniate = cinema.coordinates?.convertToCLLocationCoordinate2D() {
                        Marker(cinema.name, coordinate: coordniate)
                    }
                }
            }
            .frame(height: 200)
            .cornerRadius(10)
            .padding()

            List(cmvm.cinemaSearchManager.nearbyCinemas, id: \.self) { cinema in
                Button {
                    selectedCinema = selectedCinema == cinema ? nil : cinema
                } label: {
                    HStack {
                        if selectedCinema == cinema {
                            Image(systemName: "checkmark.circle.fill")
                                .tint(cmvm.cinemateColor)
                        } else {
                            Image(systemName: "checkmark.circle")
                                .tint(cmvm.cinemateColor)
                        }
                        
                        VStack(alignment: .leading) {
                            Text(cinema.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            Text(cinema.address ?? "")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Button {
                showingMap = false
            } label: {
                Text("Confirm")
                    .font(.headline)
                    .bold()
                    .tint(cmvm.cinemateColor)
            }
        }
    }
}

extension Binding where Value == String? {
    init(_ source: Binding<String?>, replacingNilWith nilReplacement: String) {
        self.init(
            get: { source.wrappedValue ?? nilReplacement },
            set: { newValue in source.wrappedValue = newValue }
        )
    }
}

#Preview {
    SetNewRecordView(cmvm: .init(), movieId: 0, posterPath: "", title: "")
}
