//
//  MapViewController.swift
//  googleMap
//
//  Created by Ke4a on 03.12.2022.
//

import GoogleMaps
import UIKit

final class MapViewController: UIViewController {
    // MARK: - Visual Components

    private var mapView: MapView {
        guard let view = self.view as? MapView
        else {
            let currentView = MapView()
            currentView.controller = self
            self.view = currentView
            return currentView
        }

        return view
    }

    // MARK: - Private Properties

    private var presenter: MapViewOutput?

    // MARK: - Initialization

    init(_ presenter: MapViewOutput) {
        super.init(nibName: nil, bundle: nil)
        self.presenter = presenter
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        super.loadView()
        let view = MapView()
        view.controller = self

        self.view = view
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.setupUI()
        setupNavBar()
        presenter?.viewDidLoadScreen()
    }

    /// Hide navigation bar.
    func setupNavBar() {
        self.navigationController?.isNavigationBarHidden = true
    }
}

// MARK: - MapViewOutput

extension MapViewController: MapViewOutput {
    func viewUpdateVisableMarks(_ visableRegion: GMSVisibleRegion) {
        presenter?.viewUpdateVisableMarks(visableRegion)
    }

    func viewDidLoadScreen() {
        presenter?.viewDidLoadScreen()
    }
    
    func viewShowLocation() {
        presenter?.viewShowLocation()
    }

    func viewShowRoute(_ path: PathChoice) {
        presenter?.viewShowRoute(path)
    }

    func viewMarkingRoute(_ on: Bool) {
        presenter?.viewMarkingRoute(on)
    }
}

// MARK: - MapViewInput

extension MapViewController: MapViewInput {
    func setInfoPanel(firstLineText: String,
                      secondLineText: String,
                      previousButtonIsEnabled previous: Bool,
                      nextButtonIsEnabled next: Bool
    ) {
        mapView.setInfoPanel(firstLineText: firstLineText, secondLineText: secondLineText,
                             previousButtonIsEnabled: previous, nextButtonIsEnabled: next)
    }

    func showRoute(_ coordinates: [CLLocationCoordinate2D]) {
        mapView.showRoute(coordinates)
    }

    func showLocation(_ coordinate: CLLocationCoordinate2D) {
        mapView.showLocation(coordinate)
    }

    var locationEnabled: Bool {
        get {
            mapView.locationEnabled
        }
        set {
            mapView.locationEnabled = newValue
        }
    }

    func createMarker(_ coordinate: CLLocationCoordinate2D) -> GMSMarker {
        mapView.createMarker(coordinate)
    }

    var visibleRegion: GMSVisibleRegion {
        mapView.visibleRegion
    }
}

// MARK: - GMSMapViewDelegate

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        presenter?.viewUpdateVisableMarks(mapView.projection.visibleRegion())
    }
}
