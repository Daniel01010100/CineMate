//
//  NearbyCinemaView.swift
//  Cinemate
//
//  Created by YUDONG LU on 1/10/2025.
//

import SwiftUI
import MapKit

struct NearbyCinemaView: View {
    var cmvm: CineMateViewModel
    @State private var _keyword: String = ""
    @Binding var showingMap: Bool
    @Binding var selectedCinema: CinemaModel?
    
    var body: some View {
        VStack {
            TextField("Search cinemas", text: $_keyword)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .textFieldStyle(.roundedBorder)
                .padding()
                .onChange(of: _keyword) {
                    cmvm.cinemaSearchManager.searchCinemasByKeyword(_keyword)
                }

            // Call the function of cinemaSearchManager (a service provided by cmvm) to search for cinemas.
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

            // Provide a list of cinemas based on the search results.
            List(cmvm.cinemaSearchManager.nearbyCinemas, id: \.self) { cinema in
                Button {
                    selectedCinema = selectedCinema == cinema ? nil : cinema
                } label: {
                    // Used to indicate whether the cinema is chosen or not.
                    HStack {
                        if selectedCinema == cinema {
                            Image(systemName: "checkmark.circle.fill")
                                .tint(cmvm.cinemateColor)
                        } else {
                            Image(systemName: "checkmark.circle")
                                .tint(cmvm.cinemateColor)
                        }
                        // The cinema's info, including name and address.
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
                self.showingMap = false
                self._keyword = ""
                cmvm.cinemaSearchManager.clearSearchResults()
            } label: {
                Text(selectedCinema == nil ? "Dismiss" : "Confirm")
                    .font(.headline)
                    .bold()
                    .tint(cmvm.cinemateColor)
            }
        }
    }
}

#Preview {
    NearbyCinemaView(
        cmvm: .init(),
        showingMap: .constant(true),
        selectedCinema: .constant(nil))
}
