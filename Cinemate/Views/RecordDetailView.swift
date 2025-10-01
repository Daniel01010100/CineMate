//
//  RecordDetailView.swift
//  Cinemate
//
//  Created by YUDONG LU on 30/9/2025.
//

import SwiftUI
import MapKit

struct RecordDetailView: View {
    var cmvm: CineMateViewModel
    var movieId: Int    // The id of the chosen movie
    var posterPath: String  // The poster's path of the chosen movie
    var title: String   // The title of the chosen movie
    var isEditing: Bool = false    // Used for
    @Environment(\.dismiss) private var _dismiss
    @State private var _showingMap: Bool = false
    @State private var _cinema: CinemaModel? = nil
    @State private var _date: Date = Date()
    @State private var _format: ViewingFormat = .standard2D
    @State private var _rating: Double = 0
    @State private var _review: String = ""
    @State private var _companions: [CompanionModel] = []
    @State private var _name: String = ""
    @State private var _relationship: String = ""
    
    // For creating new record.
    init(cmvm: CineMateViewModel, movieId: Int, posterPath: String, title: String) {
        self.isEditing = false
        self.cmvm = cmvm
        self.movieId = movieId
        self.posterPath = posterPath
        self.title = title
    }
    
    // For editing the record already exists.
    init(cmvm: CineMateViewModel, record: MovieRecords) {
        self.isEditing = true
        self.cmvm = cmvm
        self.movieId = record.movieId
        self.posterPath = record.moviePosterURLSnapshot ?? ""
        self.title = record.movieTitle ?? ""
        self._cinema = cmvm.getCinemaById(record.cinemaId)
        self._date = record.dateWatched ?? Date()
        self._format = record.viewingFormat[0]
        self._rating = record.userRating ?? 0
        self._review = record.review ?? ""
        self._companions = record.companions
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text(self.isEditing ? "Edit Record" : "Create New Record")
                    .font(.largeTitle.bold())
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.top, 16)
                
                // Section for choosing cinema (using NearbyCinemaView)
                VStack(alignment: .leading, spacing: 8) {
                    Text("Cinema")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Button(action: {
                        self._showingMap.toggle()
                    }) {
                        HStack(spacing: 8) {
                            Image(systemName: "map")
                            // If the user has chosen a cinema, the name of cinema will be directly indicated outside the sheet.
                            Text(_cinema == nil ? "Select" : "Choosed Cinema: ")
                            if let cinema = _cinema {
                                Text("\(cinema.name)")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.gray.opacity(0.1))
                        .cornerRadius(10)
                    }
                }
                
                // Section for setting the date and time watched
                HStack(alignment: .center, spacing: 8) {
                    Text("Date Watched")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    DatePicker("Date", selection: $_date, displayedComponents: [.date, .hourAndMinute])
                        .datePickerStyle(.compact)
                        .padding(10)
                        .labelsHidden()
                }
                
                /* Section for choosing the viewing format, such as 3D. It's supposed to have more than one type. However, due to time limitation, it hasn't been implemented. Currently, only one format can be selected. */
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
                    .pickerStyle(.menu)
                    .padding(10)
                    .background(.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                
                // Section for rating the movie. Please use slide bar to control.
                VStack(alignment: .leading, spacing: 8) {
                    Text("Rating")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    VStack {
                        Slider(value: $_rating, in: 0...5, step: 0.5)
                            .tint(cmvm.cinemateColor)
                            .frame(width: 250)
                            .padding()
                        
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { idx in
                                let score = Double(idx)
                                let imgName = self._rating >= score ? "star.fill"
                                : self._rating >= score - 0.5 ? "star.lefthalf.fill" : "star"
                                
                                Image(systemName: imgName)
                                    .foregroundColor(score <= _rating + 0.5 ? cmvm.cinemateColor : .gray)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
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
                
                // For recording the information of people who watched movies with you.
                CompanionView(_companions: $_companions, _name: $_name, _relationship: $_relationship)
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 32)
            
            Spacer()
            
            // Save records to Core Data.
            Button(action: {
                let companion = CompanionModel(_name, _relationship)
                _companions.append(companion)
                cmvm.addMovieRecord(movieId, posterPath, title, _cinema?.id, _date, [_format], Double(_rating), _review, _companions)
                if let cinema = self._cinema {
                    cmvm.addCinema(cinema)
                }
                _dismiss()
            }, label: {
                Text("Save")
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

struct CompanionView: View {
    @State private var _isAddingCompanion: Bool = false
    @State private var _selectedCompanion: CompanionModel? = nil
    @Binding var _companions: [CompanionModel]
    @Binding var _name: String
    @Binding var _relationship: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Companions")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Reveal the information of the added people, including their name and relationship.
            ScrollView(.horizontal) {
                HStack {
                    ForEach(self._companions, id: \.self) { companion in
                        Text("\(companion.name ?? "")(\(companion.relationship ?? ""))")
                            .onLongPressGesture {
                                if let idx = self._companions.firstIndex(of: companion) {
                                    self._companions.remove(at: idx)
                                }
                            }
                    }
                }
            }
            .padding()
            
            if self._isAddingCompanion {
                TextField("Companion's name", text: $_name)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(10)
                    .background(.gray.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.primary)
                TextField("Your relationship with the companion", text: $_relationship)
                    .textInputAutocapitalization(.never)
                    .disableAutocorrection(true)
                    .padding(10)
                    .background(.gray.opacity(0.1))
                    .cornerRadius(10)
                    .foregroundColor(.primary)
                
                HStack(spacing: 30) {
                    Button("Cancel") {
                        self._name = ""
                        self._name = ""
                        self._isAddingCompanion = false
                    }
                    
                    Button("Confirm Add") {
                        self.addCompanion()
                        self._name = ""
                        self._relationship = ""
                        self._isAddingCompanion = false
                    }
                }
            } else {
                Button(action: {
                    self._isAddingCompanion = true
                }, label: {
                    Image(systemName: "plus.circle")
                    Text("Add a companion")
                })
                .tint(Color(red: 30/255, green: 58/255, blue: 138/255))
            }
        }
    }
    
    private func addCompanion() {
        let companion = CompanionModel(_name, _relationship)
        self._companions.append(companion)
    }
}

#Preview {
    RecordDetailView(cmvm: .init(), movieId: 0, posterPath: "", title: "")
}
