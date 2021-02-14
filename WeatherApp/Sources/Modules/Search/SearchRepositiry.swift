//
//  SearchRepositiry.swift
//  WeatherApp
//
//  Created by sahey on 14.02.2021.
//

import CoreLocation

enum Search {
    struct Request {
        let query: String
    }

    struct Response {
        let places: [Place]
    }

    struct ViewModel {
        let items: [Item]
    }

    enum Error: Swift.Error {
        case coreLocation(error: Swift.Error)
    }
}

extension Search.Response {
    struct Place {
        let identifier: Int
        let location: CLLocationCoordinate2D
        let name: String
        let country: String?
    }
}

extension Search.ViewModel {
    struct Item {
        let idintifier: Int
        let title: String
        let subtitle: String?
    }
}

protocol SearchRepository {
    func reverseGecode(request: Search.Request, completion: @escaping (Result<Search.Response, Search.Error>) -> Void)
}

final class SearchRepositoryImpl: SearchRepository {
    private let geocoder: Geocoder

    init(geocoder: Geocoder) {
        self.geocoder = geocoder
    }

    func reverseGecode(request: Search.Request, completion: @escaping (Result<Search.Response, Search.Error>) -> Void) {
        geocoder.geocodeAddressString(request.query, in: nil, preferredLocale: Locale.current) { [weak self] (places: [CLPlacemark]?, error: Error?) in
            guard let self = self, let places = places else {
                if let error = error {
                    completion(.failure(.coreLocation(error: error)))
                } else {
                    completion(.success(Search.Response(places: [])))
                }
                return
            }
            let response = Search.Response(
                places: places.enumerated().compactMap(self.toDomainSpecific)
            )
            completion(.success(response))
        }
    }

    private func toDomainSpecific(index: Int, place: CLPlacemark) -> Search.Response.Place? {
        guard let location = place.location, let name = place.name else { return nil }
        return Search.Response.Place(
            identifier: index,
            location: location.coordinate,
            name: name,
            country: place.country
        )
    }
}
