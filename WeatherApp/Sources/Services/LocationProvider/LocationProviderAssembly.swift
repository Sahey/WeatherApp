//
//  LocationProviderAssembly.swift
//  WeatherApp
//
//  Created by sahey on 13.02.2021.
//

final class LocationProviderAssembly: DependencyAssembly {
    func assemble(container: DependencyContainer) {
        container.register(LocationProvider.self) { _ in
            LocationProviderImpl()
        }
    }
}
