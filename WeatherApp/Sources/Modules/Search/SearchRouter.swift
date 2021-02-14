//
//  SearchRouter.swift
//  WeatherApp
//
//  Created by sahey on 15.02.2021.
//

import UIKit

protocol SearchRouter {
    func routeToForecast(place: Search.Response.Place)
}

final class SearchRouterImpl: SearchRouter {
    private let weatherBuilder: WeatherBuilder
    weak var viewController: UIViewController?

    init(weatherBuilder: WeatherBuilder) {
        self.weatherBuilder = weatherBuilder
    }

    func routeToForecast(place: Search.Response.Place) {
        let weather = weatherBuilder.build(input: WeatherBuilderInput(place: place))
            .title(place.name)
        viewController?.navigationController?.pushViewController(weather, animated: true)
    }
}
