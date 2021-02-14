//
//  ServiceAssembly.swift
//  WeatherApp
//
//  Created by sahey on 13.02.2021.
//

extension ComponentAssembly {
    static var services: DependencyAssembly {
        ComponentAssembly(
            WeatherApiServiceAssembly(),
            LocationProviderAssembly(),
            GeocoderAssembly()
        )
    }
}
