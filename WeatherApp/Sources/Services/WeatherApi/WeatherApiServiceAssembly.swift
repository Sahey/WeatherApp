//
//  WeatherApiServiceAssembly.swift
//  WeatherApp
//
//  Created by sahey on 13.02.2021.
//

final class WeatherApiServiceAssembly: DependencyAssembly {
    func assemble(container: DependencyContainer) {
        container.register(WeatherApiService.self) { _ in
            WeatherApiServiceImpl()
        }
    }
}
