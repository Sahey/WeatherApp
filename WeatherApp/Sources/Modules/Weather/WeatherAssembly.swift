//
//  WeatherAssembly.swift
//  WeatherApp
//
//  Created by sahey on 13.02.2021.
//

import Foundation

final class WeatherAssembly: DependencyAssembly {
    func assemble(container: DependencyContainer) {
        container.register(WeatherBuilder.self) { container in
            let builder = WeatherBuilderImpl(
                apiService: container.resolve(WeatherApiService.self)!,
                locationProvider: container.resolve(LocationProvider.self)!
            )
            return builder
        }
    }
}
