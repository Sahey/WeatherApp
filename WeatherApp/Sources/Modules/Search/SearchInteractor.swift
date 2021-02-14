//
//  SearchInteractor.swift
//  WeatherApp
//
//  Created by sahey on 14.02.2021.
//

import Combine
import CoreLocation
import Foundation

protocol SearchInteractor {
    func didSearch(query: String)
    func didSelectLocation(identifier: Int)
}

final class SearchInteractorImpl {
    private let presenter: SearchPresenter
    private let repository: SearchRepository
    private let router: SearchRouter
    private let query = PassthroughSubject<String, Never>()
    private var cancelable: AnyCancellable?
    private var places: [Int: Search.Response.Place] = [:]

    init(presenter: SearchPresenter, repository: SearchRepository, router: SearchRouter) {
        self.presenter = presenter
        self.repository = repository
        self.router = router
        setup()
    }

    private func setup() {
        cancelable = query
            .debounce(for: 0.3, scheduler: DispatchQueue.main)
            .flatMap { [weak self] query -> AnyPublisher<Search.Response, Never> in
                guard let self = self else {
                    return Empty().eraseToAnyPublisher()
                }
                return self.reverseGeocode(query: query)
                    .catch { [weak self] error -> AnyPublisher<Search.Response, Never> in
                        self?.places.removeAll()
                        self?.presenter.present(error: error)
                        return Empty<Search.Response, Never>().eraseToAnyPublisher()
                    }
                    .eraseToAnyPublisher()
            }
            .sink { [weak self] response in
                response.places.forEach {
                    self?.places[$0.identifier] = $0
                }
                self?.presenter.present(response: response)
            }
    }

    private func reverseGeocode(query: String) -> AnyPublisher<Search.Response, Search.Error> {
        Deferred {
            Future { promise in
                let request = Search.Request(query: query)
                self.repository.reverseGecode(request: request) { result in
                    promise(result)
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

extension SearchInteractorImpl: SearchInteractor {
    func didSearch(query text: String) {
        query.send(text)
    }

    func didSelectLocation(identifier: Int) {
        guard let place = places[identifier] else { return }
        router.routeToForecast(place: place)
    }
}
