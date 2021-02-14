//
//  SearchRouter.swift
//  WeatherApp
//
//  Created by sahey on 15.02.2021.
//

import UIKit

protocol SearchRouter {
    func routeToForecast(place: Search.Response.Place)
    func routeToForecast(input: OpenForecastFlow.Input)
}

final class SearchRouterImpl: SearchRouter {
    private let weatherBuilder: WeatherBuilder
    weak var viewController: UIViewController?

    init(weatherBuilder: WeatherBuilder) {
        self.weatherBuilder = weatherBuilder
    }

    func routeToForecast(place: Search.Response.Place) {
        let input = WeatherBuilderInput(
            place: WeatherBuilderInput.Place(
                name: place.name,
                location: place.location
            )
        )
        let weather = weatherBuilder.build(input: input)
            .title(place.name)
        viewController?.navigationController?.pushViewController(weather, animated: true)
    }

    func routeToForecast(input: OpenForecastFlow.Input) {
        let weatherInput = WeatherBuilderInput(
            place: WeatherBuilderInput.Place(
                name: input.name,
                location: input.location
            )
        )
        let weather = weatherBuilder.build(input: weatherInput)
            .title(input.name ?? "Deeplink")
        viewController?.navigationController?.pushViewController(weather, animated: true)
    }
}
