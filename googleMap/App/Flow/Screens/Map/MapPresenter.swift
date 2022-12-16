//
//  MapPresenter.swift
//  googleMap
//
//  Created by Ke4a on 08.12.2022.
//

import Foundation
import GoogleMaps
import RealmSwift
import RxSwift

enum PathChoice {
    case previous
    case next
}

protocol MapViewOutput {
    /// View requested start marking route.
    func viewMarkingRoute(_ on: Bool)
    /// View requested shows traveled Route.
    func viewShowRoute(_ route: PathChoice)
    /// View requested update visable marks
    /// - Parameter visableRegion: Visable region map.
    func viewUpdateVisableMarks(_ visableRegion: GMSVisibleRegion)
    /// View requested user location.
    func viewShowLocation()
    /// View shows the screen.
    func viewDidLoadScreen()
}

protocol MapViewInput: AnyObject {
    /// Controls whether the My Location dot and accuracy circle is enabled. Defaults to false.
    var locationEnabled: Bool { get set }
    /// Creates location marker on map.
    /// - Parameter coordinate: The latitude and longitude associated with a location
    /// - Returns: Marker
    func createMarker(_ coordinate: CLLocationCoordinate2D) -> GMSMarker
    /// As animateToCameraPosition:, but changes only the location of the camera.
    /// - Parameter coordinate: The latitude and longitude associated with a location.
    func showLocation(_ coordinate: CLLocationCoordinate2D)
    /// As animateToCameraPosition:, but changes only the location of the camera.
    /// - Parameter coordinates: Array  latitude and longitude associated with a location.
    func showRoute(_ coordinates: [CLLocationCoordinate2D])

    /// Set route information.
    /// - Parameters:
    ///   - firstLine: The first line of the text.
    ///   - secondLine: The second line of the text.
    func setInfoPanel(firstLineText: String,
                      secondLineText: String,
                      previousButtonIsEnabled previous: Bool,
                      nextButtonIsEnabled next: Bool)
}

final class MapPresenter {
    // MARK: - Visual Components

    weak var viewInput: MapViewInput?

    // MARK: - Private Properties

    // Routes from the database.
    private lazy var routesDb: Results<RouteModel>? = {
        do {
            return try realm.get(RouteModel.self).filter("ANY owner == %@", user)
        } catch {
            return nil
        }
    }()

    /// Checking if the route is marked on the map.
    private lazy var isMarkingRoute: Bool = false
    /// All user movement coordinates.
    private lazy var routeCoordinates: [CLLocationCoordinate2D] = []
    /// Visible markers on map.
    private lazy var visibleMarkers: [GMSMarker] = []

    /// User route.
    private var route: RouteModel? {
        willSet {
            guard let route = newValue else { return }
            routeCoordinates = route.locations.map { $0.coordinate }
        }
    }

    /// Temporary route to record.
    private var tempRoute: RouteModel? {
        willSet {
            routeCoordinates.removeAll()
        }
    }

    /// Location manager.
    private let locationManager: LocationManagerProtocol

    /// Service for working with the database.
    private var realm: RealmServiceProtocol
    /// User.
    private var user: UserModel

    /// Thread safe bag that disposes added disposables on deinit.
    private lazy var disposeBag = DisposeBag()

    // MARK: - Initialization

    init(realm: RealmServiceProtocol, locationManager: LocationManagerProtocol, user: UserModel) {
        self.realm = realm
        self.user = user
        self.locationManager = locationManager
        configureRx()
    }

    // MARK: - Private Methods

    /// Saving the route in the database.
    private  func saveRouteInDb(_ route: RouteModel) {
        do {
            try realm.update {
                user.addRoute(route)
            }
        } catch {
            print(error)
        }
    }

    /// Check the constraints in the database to save this model.
    /// - Parameter limit: Limit of records in the database. The default is 20.
    private func checkTheRouteLimitInDb(_ limit: Int = 20) {
        do {
            guard let objects = routesDb else { return }
            let count = objects.count

            if count >= limit {
                var deleteObjects: [Object] = []
                objects[0...count - limit].forEach { route in
                    // Removing children.
                    deleteObjects.append(contentsOf: Array(route.locations))
                    deleteObjects.append(route)
                }
                try realm.delete(deleteObjects)
            }
        } catch {
            print(error)
        }
    }

    /// Calculates which buttons should be disabled.
    /// - Parameters:
    ///   - index: The index of the array in the database.
    ///   - count: Number of items in the database.
    /// - Returns: A tuple of boolean values for buttons.
    private func calculateButtonIsEnabled(_ index: Int, _ count: Int) -> (previous: Bool, next: Bool) {
        let previousButton = index != count - 1 && count > 1
        let nextButton = index != 0 && count > 1

        return (previousButton, nextButton)
    }

    /// Configuration binding observables .
    private func configureRx() {
        locationManager.statusAuthorization
            .subscribe {[weak self] event in
                guard let self = self, let status = event.element else { return }

                switch status {
                case .notDetermined,
                        .restricted,
                        .denied:
                    self.viewInput?.locationEnabled = false
                case .authorizedAlways,
                        .authorizedWhenInUse:
                    self.viewInput?.locationEnabled = true
                    guard let coordinate = self.locationManager.currentLocation?.coordinate else { return }
                    self.viewInput?.showLocation(coordinate)
                @unknown default:
                    self.viewInput?.locationEnabled = false
                }
            }.disposed(by: disposeBag)

        locationManager.updateLocation
            .subscribe { [weak self] event in
                guard let self = self,
                      self.isMarkingRoute,
                      let coordinate = event.element?.coordinate else { return }

                self.routeCoordinates.append(coordinate)

                guard UIApplication.shared.applicationState != .background  else { return }

                self.viewInput?.showLocation(coordinate)
            }.disposed(by: disposeBag)
    }
}

extension MapPresenter: MapViewOutput {
    func viewUpdateVisableMarks(_ visableRegion: GMSVisibleRegion) {
        guard isMarkingRoute else { return }
        let boundsVisable = GMSCoordinateBounds(region: visableRegion)

        var visableCoordinates = routeCoordinates.filter { coordinate in
            return boundsVisable.contains(coordinate)
        }

        var newMark = visibleMarkers.filter { marker in
            guard let index = visableCoordinates.firstIndex(where: { $0.longitude == marker.position.longitude
                && $0.latitude == marker.position.latitude})
            else {
                marker.map = nil
                return false
            }

            visableCoordinates.remove(at: index)
            return true
        }

        visableCoordinates.forEach { coordinate in
            guard let mark = viewInput?.createMarker(coordinate) else { return }
            newMark.append(mark)
        }

        visibleMarkers = newMark
    }

    func viewDidLoadScreen() {
        if let routesDb = routesDb, routesDb.isEmpty {
            viewInput?.setInfoPanel(firstLineText: "Добро пожаловать",
                                    secondLineText: "Начните маршрут",
                                    previousButtonIsEnabled: false,
                                    nextButtonIsEnabled: false)
        } else {
            viewInput?.setInfoPanel(firstLineText: "Нажмите кнопку",
                                    secondLineText: "Для выбора прошлых маршрутов",
                                    previousButtonIsEnabled: true,
                                    nextButtonIsEnabled: true)
        }
    }

    func viewShowLocation() {
        guard let coordinate = self.locationManager.currentLocation?.coordinate else { return }

        viewInput?.showLocation(coordinate)
    }

    func viewShowRoute(_ path: PathChoice) {
        guard let routes = routesDb?.sorted(byKeyPath: "date", ascending: false), !routes.isEmpty else { return }

        // If there is no index, then we show the first element.
        var index = routes.firstIndex(where: { $0.id == route?.id }) ?? 0
        // If there is no route, then this is the first run, we show the first item.
        // If the index is outside the array, it exits the function.
        switch path {
        case .previous where route != nil:
            guard index < routes.count - 1 else { return }
            index += 1
        case .next where route != nil :
            guard index > 0 else { return }
            index -= 1
        default:
            break
        }
        self.route = routes[index]

        guard let route = self.route else { return }
        viewInput?.showRoute(routeCoordinates)
        let buttons = calculateButtonIsEnabled(index, routes.count)
        viewInput?.setInfoPanel(firstLineText: "\(route.getDateString)",
                                secondLineText: "\(index + 1)|\(routes.count)",
                                previousButtonIsEnabled: buttons.previous,
                                nextButtonIsEnabled: buttons.next)
    }

    func viewMarkingRoute(_ on: Bool) {
        isMarkingRoute = on
        if on {
            tempRoute = RouteModel()
            locationManager.startUpdatingLocation()
        } else {
            locationManager.stopUpdatingLocation()

            // Remove all markers from the map.
            visibleMarkers.forEach { $0.map = nil }
            visibleMarkers.removeAll()

            guard routeCoordinates.count > 4,
                  let routesDb = routesDb,
                  let tempRoute = tempRoute
            else {
                routeCoordinates = route?.getCoordinates ?? []
                viewInput?.showRoute(routeCoordinates)
                return
            }

            tempRoute.addLocation(routeCoordinates)
            self.route = tempRoute

            checkTheRouteLimitInDb()
            saveRouteInDb(tempRoute)

            viewInput?.showRoute(routeCoordinates)
            let buttons = calculateButtonIsEnabled(0, routesDb.count)
            viewInput?.setInfoPanel(firstLineText: "\(tempRoute.getDateString)",
                                    secondLineText: "\(1)|\(routesDb.count)",
                                    previousButtonIsEnabled: buttons.previous,
                                    nextButtonIsEnabled: buttons.next)

        }
    }
}
