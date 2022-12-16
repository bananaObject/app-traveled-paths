//
//  MapView.swift
//  googleMap
//
//  Created by Ke4a on 08.12.2022.
//

import GoogleMaps
import UIKit

final class MapView: UIView {
    // MARK: - Visual Components

    private lazy var trackRouteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = .green
        button.setTitle("Start a new track", for: .normal)
        button.setTitle("Finish the track", for: .selected)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.white, for: .selected)
        button.titleLabel?.font = .preferredFont(forTextStyle: .title3)
        return button
    }()

    private lazy var mapView: GMSMapView = {
        let view = GMSMapView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    private lazy var previousRouteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("previous", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .darkGray
        button.layer.cornerRadius = 8
        button.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        button.clipsToBounds = true
        return button
    }()

    private lazy var nextRouteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("next", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = previousRouteButton.backgroundColor
        button.layer.cornerRadius = previousRouteButton.layer.cornerRadius
        button.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        button.clipsToBounds = true
        return button
    }()

    private lazy var locationButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "locationArrow")
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.setImage(image, for: .normal)

        return button
    }()

    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.backgroundColor = .white
        label.layer.cornerRadius = 8
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        label.clipsToBounds = true
        return label
    }()

    // MARK: - Public Properties

    weak var controller: (MapViewOutput & GMSMapViewDelegate)?

    // MARK: - Private Properties

    /// Path.
    private lazy var route = GMSMutablePath()
    /// Past path line.
    private lazy var polyline = {
        let polyline = GMSPolyline()
        polyline.strokeColor = .red
        polyline.strokeWidth = 5
        return polyline
    }()

    // MARK: - Initialization

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setting UI Methods

    /// Settings ui components.
    func setupUI() {
        configureMap()

        addSubview(trackRouteButton)
        NSLayoutConstraint.activate([
            trackRouteButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            trackRouteButton.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            trackRouteButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            trackRouteButton.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.1)
        ])

        addSubview(mapView)
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            mapView.bottomAnchor.constraint(equalTo: trackRouteButton.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor)
        ])

        addSubview(previousRouteButton)
        NSLayoutConstraint.activate([
            previousRouteButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            previousRouteButton.leftAnchor.constraint(equalTo: safeAreaLayoutGuide.leftAnchor, constant: 10),
            previousRouteButton.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.07),
            previousRouteButton.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25)

        ])

        addSubview(nextRouteButton)
        NSLayoutConstraint.activate([
            nextRouteButton.topAnchor.constraint(equalTo: previousRouteButton.topAnchor),
            nextRouteButton.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -10),
            nextRouteButton.heightAnchor.constraint(equalTo: previousRouteButton.heightAnchor),
            nextRouteButton.widthAnchor.constraint(equalTo: previousRouteButton.widthAnchor)
        ])

        addSubview(infoLabel)
        NSLayoutConstraint.activate([
            infoLabel.topAnchor.constraint(equalTo: nextRouteButton.topAnchor),
            infoLabel.leadingAnchor.constraint(equalTo: previousRouteButton.trailingAnchor),
            infoLabel.trailingAnchor.constraint(equalTo: nextRouteButton.leadingAnchor),
            infoLabel.heightAnchor.constraint(equalTo: nextRouteButton.heightAnchor, multiplier: 1.5)
        ])

        addSubview(locationButton)
        NSLayoutConstraint.activate([
            locationButton.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -25),
            locationButton.leadingAnchor.constraint(equalTo: mapView.leadingAnchor, constant: 15),
            locationButton.widthAnchor.constraint(equalTo: mapView.widthAnchor, multiplier: 0.1),
            locationButton.heightAnchor.constraint(equalTo: locationButton.widthAnchor)
        ])

        trackRouteButton.addTarget(self, action: #selector(routeMarkingButtonAction), for: .touchUpInside)
        previousRouteButton.addTarget(self, action: #selector(previousRouteButtonAction), for: .touchUpInside)
        nextRouteButton.addTarget(self, action: #selector(nextRouteButtonAction), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(locationButtonAction), for: .touchUpInside)

    }
    // MARK: - Private Methods

    /// Configuration map view.
    private func configureMap() {
        mapView.delegate = controller
        mapView.setMinZoom(10, maxZoom: 15)
    }

    /// New route for map.
    /// - Parameter coordinate: User coordinate.
    private func newRoute(_ coordinates: [CLLocationCoordinate2D]) {
        coordinates.forEach { value in
            route.add(value)
        }
        polyline.path = route
        polyline.map = mapView
    }

    /// Delete route from map.
    private func deleteRoute() {
        route.removeAllCoordinates()
        polyline.path = route
        polyline.map = nil
    }

    // MARK: - Actions

    /// Action button tracking route .
    /// - Parameter sender: Button.
    @objc private func routeMarkingButtonAction(_ sender: UIButton) {
        let buttonIsSelected = !sender.isSelected
        trackRouteButton.isSelected = buttonIsSelected
        trackRouteButton.backgroundColor = buttonIsSelected ? .red :.green
        nextRouteButton.isHidden = buttonIsSelected
        previousRouteButton.isHidden = buttonIsSelected
        infoLabel.isHidden = buttonIsSelected
        controller?.viewMarkingRoute(buttonIsSelected)
    }

    /// Action button previous route .
    @objc private func previousRouteButtonAction() {
        controller?.viewShowRoute(.previous)
    }

    /// Action button next route .
    @objc private func nextRouteButtonAction() {
        controller?.viewShowRoute(.next)
    }

    /// Action button location .
    @objc private func locationButtonAction() {
        controller?.viewShowLocation() }
}

// MARK: - MapViewInput

extension MapView: MapViewInput {
    func setInfoPanel(firstLineText: String,
                      secondLineText: String,
                      previousButtonIsEnabled previous: Bool,
                      nextButtonIsEnabled next: Bool
    ) {
        infoLabel.text = "\(firstLineText)\n\(secondLineText)"

        if nextRouteButton.isEnabled != next {
            nextRouteButton.isEnabled = next
            nextRouteButton.backgroundColor = next ? .darkGray : .lightGray

        }

        if previousRouteButton.isEnabled != previous {
            previousRouteButton.isEnabled = previous
            previousRouteButton.backgroundColor = previous ? .darkGray : .lightGray
        }
    }

    var locationEnabled: Bool {
        get {
            mapView.isMyLocationEnabled
        }
        set {
            mapView.isMyLocationEnabled = newValue
        }
    }

    var visibleRegion: GMSVisibleRegion {
        mapView.projection.visibleRegion()
    }

    func createMarker(_ coordinate: CLLocationCoordinate2D) -> GMSMarker {
        let mark = GMSMarker(position: coordinate)
        let dotSize = 5
        let iconView = UIView(frame: .init(x: 0, y: 0, width: dotSize, height: dotSize))
        iconView.backgroundColor = .red
        iconView.layer.cornerRadius = iconView.frame.width / 2
        iconView.clipsToBounds = true
        mark.iconView = iconView
        mark.map = mapView
        return mark
    }

    func showLocation(_ coordinate: CLLocationCoordinate2D) {
        mapView.animate(to: .camera(withTarget: coordinate, zoom: 15))
    }

    func showRoute(_ coordinates: [CLLocationCoordinate2D]) {
        deleteRoute()
        newRoute(coordinates)

        let bounds = GMSCoordinateBounds(path: route)
        mapView.animate(with: GMSCameraUpdate.fit(bounds, withPadding: 100))
    }
}
