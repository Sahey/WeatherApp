//
//  WeatherBuilder.swift
//  WeatherApp
//
//  Created by sahey on 11.02.2021.
//

import UIKit

struct WeatherBuilderInput {
    let place: Search.Response.Place?

    static var `default`: WeatherBuilderInput { WeatherBuilderInput(place: nil) }
}

protocol WeatherBuilder {
    func build(input: WeatherBuilderInput) -> UIViewController
}

final class WeatherBuilderImpl: WeatherBuilder {
    private let apiService: WeatherApiService
    private let locationProvider: LocationProvider

    init(apiService: WeatherApiService, locationProvider: LocationProvider) {
        self.apiService = apiService
        self.locationProvider = locationProvider
    }

    func build(input: WeatherBuilderInput) -> UIViewController {
        let view = WeatherViewController(nibName: nil, bundle: nil)
        let presenter = WeatherPresenterImpl(view: view)
        let repository = WeatherRepositoryImpl(apiService: apiService, locationProvider: locationProvider)
        let router = WeatherRouterImpl()
        let interactor = WeatherInteractorImpl(
            presenter: presenter,
            router: router,
            repository: repository,
            selectedPlace: input.place
        )
        view.interactor = interactor
        return view
    }
}
