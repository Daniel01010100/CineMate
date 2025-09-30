//
//  Cinemas.swift
//  Cinemate
//
//  Created by YUDONG LU on 19/9/2025.
//

import Foundation
import CoreLocation

struct CinemaModel: Codable, Identifiable, Hashable {
    var id: UUID = UUID()
    var name: String = ""
    var address: String? = nil
    var coordinates: Coordinates? = nil
}

struct Coordinates: Codable, Hashable {
    var latitude: Double
    var longitude: Double
    
    init(_ latitude: Double, _ longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    mutating func update(_ latitude: Double, _ longitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func convertToCLLocationCoordinate2D() -> CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
