//
//  MovieRecords.swift
//  Cinemate
//
//  Created by YUDONG LU on 17/9/2025.
//

import Foundation
import CoreLocation

struct MovieRecords: Codable {
    var movieId: Int = 0
    var place: CLLocationCoordinate2D? = nil
    var date: Date? = nil
    var userRating: Double? = nil
}
