//
//  SearchBuilder.swift
//  WeatherApp
//
//  Created by sahey on 14.02.2021.
//

import UIKit

protocol SearchBuilder {
    func build() -> UIViewController
}

final class SearchBuilderImpl: SearchBuilder {
    private let geocoder: Geocoder
    private let weatherBuilder: WeatherBuilder

    init(geocoder: Geocoder, weatherBuilder: WeatherBuilder) {
        self.geocoder = geocoder
        self.weatherBuilder = weatherBuilder
    }

    func build() -> UIViewController {
        let presenter = SearchPresenterImpl()
        let repository = SearchRepositoryImpl(geocoder: geocoder)
        let router = SearchRouterImpl(weatherBuilder: weatherBuilder)
        let interactor = SearchInteractorImpl(presenter: presenter, repository: repository, router: router)
        let view = SearchViewController(interactor: interactor)
        presenter.view = view
        router.viewController = view
        return UINavigationController(rootViewController: view)
    }
}
