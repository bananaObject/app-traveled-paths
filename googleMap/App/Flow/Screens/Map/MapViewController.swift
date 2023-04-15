//
//  MapViewController.swift
//  googleMap
//
//  Created by Ke4a on 03.12.2022.
//

import Combine
import GoogleMaps
import UIKit

final class MapViewController: UIViewController {
    // MARK: - Visual Components

    private var mapView: MapView {
        guard let view = self.view as? MapView else {
            let correctView = MapView()
            correctView.controller = self
            return correctView
        }

        return view
    }

    // MARK: - Private Properties

    private var presenter: MapViewOutput

    // MARK: - Initialization

    init(_ presenter: MapViewOutput) {
        self.presenter = presenter

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func loadView() {
        super.loadView()

        self.view = mapView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.setupUI()
        setupNavBar()
        presenter.viewDidLoadScreen()
    }

    /// Hide navigation bar.
    func setupNavBar() {
        self.navigationController?.isNavigationBarHidden = true
    }
}

// MARK: - MapViewOutput

extension MapViewController: MapViewOutput {
    var routePublisher: AnyPublisher<[CLLocationCoordinate2D], Never> {
        presenter.routePublisher
    }

    var locationPublisher: AnyPublisher<CLLocationCoordinate2D?, Never> {
        presenter.locationPublisher
    }

    var locationEnabledPublisher: AnyPublisher<Bool, Never> {
        presenter.locationEnabledPublisher
    }

    func viewUpdateVisableMarks(_ visableRegion: GMSVisibleRegion) {
        presenter.viewUpdateVisableMarks(visableRegion)
    }

    func viewDidLoadScreen() {
        presenter.viewDidLoadScreen()
    }

    func viewShowLocation() {
        presenter.viewShowLocation()
    }

    func viewShowRoute(_ path: PathChoice) {
        presenter.viewShowRoute(path)
    }

    func viewMarkingRoute(_ isOn: Bool) {
        presenter.viewMarkingRoute(isOn)
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

    func createMarker(_ coordinate: CLLocationCoordinate2D) -> GMSMarker {
        mapView.createMarker(coordinate)
    }
}

// MARK: - GMSMapViewDelegate

extension MapViewController: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didChange position: GMSCameraPosition) {
        presenter.viewUpdateVisableMarks(mapView.projection.visibleRegion())
    }
}
