//
//  WeatherInteractor.swift
//  WeatherApp
//
//  Created by sahey on 11.02.2021.
//

import CoreLocation

protocol WeatherInteractor: AnyObject {
    func didLoadView()
    func didTapRetry()
    func didTapPermissionCancel()
    func didTapSettings()
    func willEnterForeground()
}

final class WeatherInteractorImpl {
    private let presenter: WeatherPresenter
    private let router: WeatherRouter
    private let repository: WeatherRepository
    private var selectedPlace: Search.Response.Place?

    init(presenter: WeatherPresenter, router: WeatherRouter, repository: WeatherRepository, selectedPlace: Search.Response.Place?) {
        self.presenter = presenter
        self.router = router
        self.repository = repository
        self.selectedPlace = selectedPlace
    }

    private func fetchData(request: Weather.Request) {
        presenter.present(isLoading: true)
        repository.requestData(request: request) { [weak self] result in
            defer {
                self?.presenter.present(isLoading: false)
            }
            switch result {
            case let .success(response):
                self?.presenter.present(response: response)
            case let .failure(error):
                self?.presenter.present(error: error)
            }
        }
    }

    private func fetchData(request: Weather.RequestDefault) {
        presenter.present(isLoading: true)
        repository.requestData(request: request) { [weak self] result in
            defer {
                self?.presenter.present(isLoading: false)
            }
            switch result {
            case let .success(response):
                self?.presenter.present(response: response)
            case let .failure(error):
                self?.presenter.present(error: error)
            }
        }
    }
}

extension WeatherInteractorImpl: WeatherInteractor {
    func didLoadView() {
        fetchData(request: Weather.Request(location: selectedPlace?.location))
    }

    func didTapRetry() {
        fetchData(request: Weather.Request(location: nil))
    }

    func didTapPermissionCancel() {
        fetchData(request: Weather.Request(location: .default))
    }

    func didTapSettings() {
        router.routeToSettings()
    }

    func willEnterForeground() {
        fetchData(request: Weather.RequestDefault(defaultLocation: .default))
    }
}

private extension CLLocationCoordinate2D {
    static var `default`: CLLocationCoordinate2D { CLLocationCoordinate2D(latitude: 62.028200, longitude: 129.746896) }
}
