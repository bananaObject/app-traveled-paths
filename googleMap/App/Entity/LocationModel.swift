//
//  LocationModel.swift
//  googleMap
//
//  Created by Ke4a on 10.12.2022.
//

import GoogleMaps
import RealmSwift

final class LocationModel: Object {
    @Persisted private var latitude: CLLocationDegrees
    @Persisted private var longitude: CLLocationDegrees

    convenience init(latitude: CLLocationDegrees, longitude: CLLocationDegrees) {
        self.init()
        self.latitude = latitude
        self.longitude = longitude
    }

    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(
            latitude: latitude,
            longitude: longitude)
    }
}
