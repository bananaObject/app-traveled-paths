//
//  ViewController.swift
//  googleMap
//
//  Created by Ke4a on 03.12.2022.
//

import GoogleMaps
import UIKit

class ViewController: UIViewController {
    // MARK: - Visual Components

    /// Map view.
    private lazy var mapView: GMSMapView = {
        let view = GMSMapView()
        return view
    }()

    // MARK: - Private Properties

    /// All user movement coordinates.
    private lazy var moveCoordinates: [CLLocationCoordinate2D] = []
    /// Visible markers.
    private lazy var visibleMarkers: [GMSMarker] = []

    /// Path
    private var routePath: GMSMutablePath?
    /// Past path line.
    private var route: GMSPolyline?

    /// Location manager.
    private var location: CLLocationManager?

    // MARK: - Lifecycle

    override func loadView() {
        super.loadView()
        view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureMap()
        configurePolyline()
        configureLocationManager()
    }

    // MARK: - Setting UI Methods

    /// Configuration map view.
    private func configureMap() {
        mapView.delegate = self
        mapView.setMinZoom(15, maxZoom: 25)
    }

    /// Configuration Location Manager.
    private func configureLocationManager() {
        location = CLLocationManager()
        location?.delegate = self
        location?.requestWhenInUseAuthorization()
        location?.startUpdatingLocation()
    }

    /// Configuration user coordinate line.
    private func configurePolyline() {
        route = GMSPolyline()
        route?.map = mapView
        routePath = GMSMutablePath()
    }

    // MARK: - Private Methods

    /// Creates marker on user locations.
    /// - Parameter coordinate: User coordinate.
    /// - Returns: Marker
    private func createMarker(_ coordinate: CLLocationCoordinate2D) -> GMSMarker {
        let mark = GMSMarker(position: coordinate)
        let dotSize = 5
        let iconView = UIView(frame: .init(x: dotSize, y: dotSize, width: dotSize, height: dotSize))
        iconView.backgroundColor = .red
        iconView.layer.cornerRadius = iconView.frame.width / 2
        iconView.clipsToBounds = true
        mark.iconView = iconView
        mark.map = mapView
        return mark
    }

    /// Update visable marks.
    private func updateVisableMarks() {
        let region = mapView.projection.visibleRegion()
        let boundsVisable = GMSCoordinateBounds(region: region)

        var visableCoordinates = moveCoordinates.filter { coordinate in
            return boundsVisable.contains(coordinate)
        }

        var newMark = visibleMarkers.filter { marker in
            guard let index = visableCoordinates.firstIndex(where: { $0.longitude == marker.position.longitude
                && $0.latitude == marker.position.latitude}) else {
                marker.map = nil
                return false
            }

            visableCoordinates.remove(at: index)
            return true
        }

        visableCoordinates.forEach { coordinate in
            let mark = createMarker(coordinate)
            newMark.append(mark)
        }

        visibleMarkers = newMark
    }

    /// Update visable Polyline.
    /// - Parameter coordinate: User coordinate.
    private func updatePolyline(_ coordinate: CLLocationCoordinate2D) {
        routePath?.add(coordinate)
        route?.path = routePath
    }
}

extension ViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        print(coordinate)
    }
}

extension ViewController: CLLocationManagerDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        updateVisableMarks()
    }

    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined,
                .restricted,
                .denied:
            mapView.isMyLocationEnabled = false
        case .authorizedAlways:
            mapView.isMyLocationEnabled = true
        case .authorizedWhenInUse:
            mapView.isMyLocationEnabled = true
        @unknown default:
            mapView.isMyLocationEnabled = false
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let last = locations.last else { return }
        // updatePolyline(last.coordinate)
        moveCoordinates.append(last.coordinate)
        mapView.animate(toLocation: last.coordinate)
    }
}
