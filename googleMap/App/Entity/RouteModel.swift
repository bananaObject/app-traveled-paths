//
//  RouteModel.swift
//  googleMap
//
//  Created by Ke4a on 10.12.2022.
//

import GoogleMaps
import RealmSwift

final class RouteModel: Object {
    @Persisted(primaryKey: true) private(set) var id: ObjectId
    @Persisted private(set) var date: Double = Date().timeIntervalSince1970
    @Persisted private(set) var locations: List<LocationModel>

    var getCoordinates: [CLLocationCoordinate2D] {
        locations.map({ $0.coordinate })
    }

    var getDateString: String {
        DateFormatterHelper.shared.convert(self.date)
    }

    func addLocation(_ location: CLLocationCoordinate2D) {
        let createLoaction = LocationModel(latitude: location.latitude, longitude: location.longitude)
        self.locations.append(createLoaction)
    }

    func addLocation(_ location: [CLLocationCoordinate2D]) {
        location.forEach { location in
            let createLoaction = LocationModel(latitude: location.latitude, longitude: location.longitude)
            self.locations.append(createLoaction)
        }
    }
}
