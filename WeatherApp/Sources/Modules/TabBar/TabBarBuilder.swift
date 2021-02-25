//
//  TabBarBuilder.swift
//  WeatherApp
//
//  Created by sahey on 14.02.2021.
//

import UIKit

protocol TabBarBuilder {
    func build() -> UIViewController & TabBarDeeplinkable
}

final class TabBarBuilderImpl: TabBarBuilder {
    private let weatherBuilder: WeatherBuilder
    private let searchBuilder: SearchBuilder

    init(weatherBuilder: WeatherBuilder, searchBuilder: SearchBuilder) {
        self.weatherBuilder = weatherBuilder
        self.searchBuilder = searchBuilder
    }

    func build() -> UIViewController & TabBarDeeplinkable {
        TabBarController(
            weatherModule: weatherBuilder.build(input: .default),
            searchModule: searchBuilder.build()
        )
    }
}
