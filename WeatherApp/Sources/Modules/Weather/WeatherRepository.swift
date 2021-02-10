//
//  WeatherRepository.swift
//  WeatherApp
//
//  Created by sahey on 11.02.2021.
//

import Combine
import CoreLocation
import Foundation

enum Weather {
    struct Request {
        let location: CLLocationCoordinate2D?
    }

    struct RequestDefault {
        let defaultLocation: CLLocationCoordinate2D
    }

    struct Response: Equatable {
        let temperature: Float
        let summary: String?
        let feelsLikeTemperature: Float?
        let preciptation: Preciptation?
        let humidity: Float?
        let wind: Wind?
        let visibility: Float?
        let uvIndex: Float?
        let pressure: Float?
    }

    enum ViewModel {
        case weather(data: Weather)
        case error(alert: NetworkAlert)
        case permission(alert: PermissionAlert)
    }

    enum Error: Swift.Error {
        case locationPermissionDenied
        case network(error: Swift.Error)
        case noData
    }
}

extension Weather.Response {
    struct Preciptation: Equatable {
        let intensity: Float
        let probability: Float
    }

    struct Wind: Equatable {
        let speed: Float
        let gust: Float
        let bearing: Float
    }
}

extension Weather.ViewModel {
    enum Item {
        case temperature(viewModel: TemperatureViewModel)
        case indicator(viewModel: WeatherIndicatorViewModel)
    }

    struct Section {
        let items: [Item]
    }

    struct Weather {
        let section: [Section]
    }

    struct NetworkAlert {
        let title: String
        let retry: String
    }

    struct PermissionAlert {
        let title: String
        let openSettings: String
        let cancel: String
    }
}

protocol WeatherRepository {
    func requestData(request: Weather.Request, completion: @escaping (Result<Weather.Response, Weather.Error>) -> Void)
    func requestData(request: Weather.RequestDefault, completion: @escaping (Result<Weather.Response, Weather.Error>) -> Void)
}

final class WeatherRepositoryImpl {
    private let apiService: WeatherApiService
    private let locationProvider: LocationProvider

    private var subscriptions = Set<AnyCancellable>()

    init(apiService: WeatherApiService, locationProvider: LocationProvider) {
        self.apiService = apiService
        self.locationProvider = locationProvider
    }

    private func toDomainSpecific(response: WeatherApi.Response) -> Weather.Response {
        let weather = response.currently
        var preciptation: Weather.Response.Preciptation?
        if let intensity = weather.precipIntensity, let probability = weather.precipProbability {
            preciptation = Weather.Response.Preciptation(intensity: intensity, probability: probability)
        }
        var wind: Weather.Response.Wind?
        if let speed = weather.windSpeed, let gust = weather.windGust, let bearing = weather.windBearing {
            wind = Weather.Response.Wind(speed: speed, gust: gust, bearing: bearing)
        }

        return Weather.Response(
            temperature: weather.temperature,
            summary: weather.summary,
            feelsLikeTemperature: weather.apparentTemperature,
            preciptation: preciptation,
            humidity: weather.humidity,
            wind: wind,
            visibility: weather.visibility,
            uvIndex: weather.uvIndex,
            pressure: weather.pressure
        )
    }

    private func toDomainSpecific(error: WeatherApi.Error) -> Weather.Error {
        switch error {
        case .noData:
            return .noData
        case let .network(error):
            return .network(error: error)
        case let .decoding(error):
            return .network(error: error)
        }
    }

    private func fetchWeather(request: WeatherApi.Request) -> AnyPublisher<Weather.Response, Weather.Error> {
        apiService.fetch(request: request)
            .map(toDomainSpecific)
            .mapError(toDomainSpecific)
            .eraseToAnyPublisher()
    }

    private func performFullPipeline() -> AnyPublisher<Weather.Response, Weather.Error> {
        locationProvider
            .getLocation()
            .map { WeatherApi.Request(location: $0) }
            .mapError { _ in Weather.Error.locationPermissionDenied }
            .flatMap { self.fetchWeather(request: $0) }
            .eraseToAnyPublisher()
    }

    private func requestData(request: Weather.Request) -> AnyPublisher<Weather.Response, Weather.Error> {
        if let locateion = request.location {
            return fetchWeather(request: .init(location: locateion))
        } else {
            return performFullPipeline()
        }
    }
}

extension WeatherRepositoryImpl: WeatherRepository {
    func requestData(request: Weather.Request, completion: @escaping (Result<Weather.Response, Weather.Error>) -> Void) {
        let subscription = requestData(request: request)
            .receive(on: DispatchQueue.main)
            .sink { receivedCompletion in
                guard case let .failure(error) = receivedCompletion else { return }
                completion(.failure(error))
            } receiveValue: { response in
                completion(.success(response))
            }
        subscriptions.insert(subscription)
    }

    func requestData(request: Weather.RequestDefault, completion: @escaping (Result<Weather.Response, Weather.Error>) -> Void) {
        let subscription = locationProvider
            .getLocation()
            .mapError { _ in Weather.Error.locationPermissionDenied }
            .catch { _ in
                Just(request.defaultLocation)
            }
            .map { WeatherApi.Request(location: $0) }
            .flatMap { self.fetchWeather(request: $0) }
            .receive(on: DispatchQueue.main)
            .sink { receivedCompletion in
                guard case let .failure(error) = receivedCompletion else { return }
                completion(.failure(error))
            } receiveValue: { response in
                completion(.success(response))
            }
        subscriptions.insert(subscription)
    }
}

private extension WeatherApiService {
    func fetch(request: WeatherApi.Request) -> AnyPublisher<WeatherApi.Response, WeatherApi.Error> {
        Deferred {
            Future { promise in
                fetch(request: request) { result in
                    promise(result)
                }
            }
        }
        .eraseToAnyPublisher()
    }
}

private extension LocationProvider {
    private func requestLocation() -> AnyPublisher<CLLocation, Location.Error> {
        Deferred {
            Future { promise in
                requestLocation { result in
                    promise(result)
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func requestUserPermission() -> AnyPublisher<Bool, Never> {
        Deferred {
            Future { promise in
                requestUserPermission { isGranted in
                    promise(.success(isGranted))
                }
            }
        }
        .eraseToAnyPublisher()
    }

    private func requestIfUndefined(_ error: Location.Error) -> AnyPublisher<CLLocation, Location.Error> {
        switch error {
        case .failed, .denied:
            return Fail(error: error).eraseToAnyPublisher()
        case .notDetermined:
            return requestUserPermission()
                .flatMap { isGranter in
                    isGranter ?
                        requestLocation() :
                        Fail(error: Location.Error.denied).eraseToAnyPublisher()
                }
                .eraseToAnyPublisher()
        }
    }

    func getLocation() -> AnyPublisher<CLLocationCoordinate2D, Location.Error> {
        requestLocation()
            .catch(requestIfUndefined)
            .map { $0.coordinate }
            .eraseToAnyPublisher()
    }
}
