//
//  RootAssembly.swift
//  WeatherApp
//
//  Created by sahey on 14.02.2021.
//

final class RootAssembly: DependencyAssembly {
    func assemble(container: DependencyContainer) {
        container.register(RootBuilder.self) { container in
            let builder = RootBuilderImpl(
                tabBarBuilder: container.resolve(TabBarBuilder.self)!
            )
            return builder
        }
    }
}
