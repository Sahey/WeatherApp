//
//  TabBarAssembly.swift
//  WeatherApp
//
//  Created by sahey on 14.02.2021.
//

final class TabBarAssembly: DependencyAssembly {
    func assemble(container: DependencyContainer) {
        container.register(TabBarBuilder.self) { container in
            TabBarBuilderImpl(
                weatherBuilder: container.resolve(WeatherBuilder.self)!
            )
        }
    }
}
