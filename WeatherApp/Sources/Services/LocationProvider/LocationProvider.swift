//
//  LocationProvider.swift
//  WeatherApp
//
//  Created by sahey on 11.02.2021.
//

import CoreLocation

enum Location {
    enum Status {
        case notDetermined
        case denied
        case allowed
    }

    enum Error: Swift.Error {
        case failed(error: Swift.Error)
        case denied
        case notDetermined
    }
}

protocol LocationProvider {
    func requestUserPermission(completion: @escaping (Bool) -> Void)
    func requestLocation(completion: @escaping (Result<CLLocation, Location.Error>) -> Void)
}

final class LocationProviderImpl: NSObject {
    private lazy var locationManager: CLLocationManager = {
        let locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        return locationManager
    }()

    private var onRequestLocation: ((Result<CLLocation, Location.Error>) -> Void)?
    private var onRequestPermission: ((Bool) -> Void)?
}

extension LocationProviderImpl: LocationProvider {
    private var permissionStatus: Location.Status {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return .notDetermined
        case .restricted, .denied:
            return .denied
        case .authorizedAlways, .authorizedWhenInUse:
            return .allowed
        @unknown default:
            return .denied
        }
    }

    func requestUserPermission(completion: @escaping (Bool) -> Void) {
        onRequestPermission = completion
        locationManager.requestWhenInUseAuthorization()
    }

    func requestLocation(completion: @escaping (Result<CLLocation, Location.Error>) -> Void) {
        let status = permissionStatus
        switch status {
        case .notDetermined:
            completion(.failure(.notDetermined))
        case .denied:
            completion(.failure(.denied))
        case .allowed:
            if let location = locationManager.location {
                completion(.success(location))
            } else {
                onRequestLocation = completion
                locationManager.requestLocation()
            }
        }
    }
}

extension LocationProviderImpl: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        onRequestLocation?(.success(location))
        onRequestLocation = nil
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        onRequestLocation?(.failure(.failed(error: error)))
        onRequestLocation = nil
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            onRequestPermission?(true)
            onRequestPermission = nil
        case .restricted, .denied:
            onRequestPermission?(false)
            onRequestPermission = nil
        case .notDetermined: ()
        @unknown default: ()
        }
    }
}
