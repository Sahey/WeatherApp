//
//  GeocoderAssembly.swift
//  WeatherApp
//
//  Created by sahey on 14.02.2021.
//

import CoreLocation

final class GeocoderAssembly: DependencyAssembly {
    func assemble(container: DependencyContainer) {
        container.register(Geocoder.self) { _ in
            CLGeocoder()
        }
    }
}
