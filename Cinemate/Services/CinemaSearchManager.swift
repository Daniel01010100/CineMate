//
//  CinemaSearchManager.swift
//  Cinemate
//
//  Created by YUDONG LU on 30/9/2025.
//

import Foundation
import MapKit
import CoreLocation
import Observation

@Observable
class CinemaSearchManager: NSObject, CLLocationManagerDelegate {
    var nearbyCinemas: [CinemaModel] = []
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        locationManager.requestLocation()
    }

    /**
     Search cinema based on the passed keyword.
     
     - Parameters:
        keyword: String The keyword for searching cinema, such as "Bondi cinema"
     */
    func searchCinemasByKeyword(_ keyword: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = keyword
        request.resultTypes = .pointOfInterest
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self, let response else {
                print("Keyword search failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.nearbyCinemas = response.mapItems.map { item in
                    CinemaModel(
                        name: item.name ?? "Unknown",
                        address: item.placemark.title,
                        coordinates: Coordinates(
                            item.placemark.coordinate.latitude,
                            item.placemark.coordinate.longitude)
                    )
                }
            }
        }
    }
    
    /**
     Search nearby cinemas based on user's location, requiring location services permission.
     */
    func searchNearbyCinemas() {
        guard let userLocation = locationManager.location else {
            print("Location not available")
            return
        }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "cinema"
        request.resultTypes = .pointOfInterest
        request.region = MKCoordinateRegion(center: userLocation.coordinate,
                                            latitudinalMeters: 10000,
                                            longitudinalMeters: 10000)
        
        let search = MKLocalSearch(request: request)
        search.start { [weak self] response, error in
            guard let self, let response else {
                print("Nearby search failed: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            DispatchQueue.main.async {
                self.nearbyCinemas = response.mapItems.map { item in
                    CinemaModel(
                        name: item.name ?? "Unknown",
                        address: item.placemark.title,
                        coordinates: Coordinates(
                            item.placemark.coordinate.latitude,
                            item.placemark.coordinate.longitude)
                    )
                }
            }
        }
    }
    
    func clearSearchResults() {
        self.nearbyCinemas.removeAll()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Successfully updated location: \(locations.first?.coordinate)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to update location: \(error.localizedDescription)")
    }
}
