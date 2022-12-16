//
//  LocationManager.swift
//  googleMap
//
//  Created by Ke4a on 15.12.2022.
//

import CoreLocation
import Foundation
import GoogleMaps
import RxSwift

/// The object that you use to start and stop the delivery of location-related events to your app.
protocol LocationManagerProtocol {
    /// Updated location.
    var updateLocation: Observable<CLLocation> { get }
    /// The current authorization status for the app.
    var statusAuthorization: Observable<CLAuthorizationStatus> { get }
    /// The most recently retrieved user location.
    var currentLocation: CLLocation? { get }
    /// Starts the generation of updates that report the user’s current location.
    func startUpdatingLocation()
    /// Stops the generation of location updates.
    func stopUpdatingLocation()
}

/// The object that you use to start and stop the delivery of location-related events to your app.
class LocationManager: NSObject {
    // MARK: - Private Properties

    /// Location manager.
    private lazy var manager: CLLocationManager = CLLocationManager()
    private var location = PublishSubject<CLLocation>()
    private var status = PublishSubject<CLAuthorizationStatus>()

    // MARK: - Initialization

    override init() {
        super.init()
        configureLocationManager()
    }

    // MARK: - Private Methods

    /// Configuration location manager.
    private func configureLocationManager() {
        manager.delegate = self
        manager.allowsBackgroundLocationUpdates = true
        manager.requestWhenInUseAuthorization()
        manager.startMonitoringSignificantLocationChanges()
        manager.pausesLocationUpdatesAutomatically = false
    }
}

// MARK: - LocationManagerProtocol

extension LocationManager: LocationManagerProtocol {
    var updateLocation: Observable<CLLocation> {
        location.asObservable()
    }

    var statusAuthorization: Observable<CLAuthorizationStatus> {
        status.asObservable()
    }

    var currentLocation: CLLocation? {
        manager.location
    }

    func startUpdatingLocation() {
        manager.startUpdatingLocation()
    }

    func stopUpdatingLocation() {
        manager.stopUpdatingLocation()
    }

}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        self.status.onNext(status)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }

        location.onNext(last)
    }
}
