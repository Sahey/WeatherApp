//
//  SearchAssembly.swift
//  WeatherApp
//
//  Created by sahey on 14.02.2021.
//

final class SearchAssembly: DependencyAssembly {
    func assemble(container: DependencyContainer) {
        container.register(SearchBuilder.self) { container in
            SearchBuilderImpl(
                geocoder: container.resolve(Geocoder.self)!,
                weatherBuilder: container.resolve(WeatherBuilder.self)!
            )
        }
    }
}
