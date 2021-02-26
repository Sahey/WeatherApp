//
//  ApiService.swift
//  WeatherApp
//
//  Created by sahey on 11.02.2021.
//

import CoreLocation

enum WeatherApi {
    struct Request {
        let location: CLLocationCoordinate2D
    }
    struct Response: Decodable {
        struct Weather: Decodable {
//            "time": 1537882620,
            let time: Double
//            "summary": "Clear",
            let summary: String?
//            "icon": "clear-day",
            let icon: String?
//            "precipIntensity": 0,
            let precipIntensity: Float?
//            "precipProbability": 0,
            let precipProbability: Float?
//            "temperature": 40.46,
            let temperature: Float
//            "apparentTemperature": 33.75,
            let apparentTemperature: Float?
//            "dewPoint": 29.59,
            let dewPoint: Float?
//            "humidity": 0.65,
            let humidity: Float?
//            "pressure": 1025.41,
            let pressure: Float?
//            "windSpeed": 11.15,
            let windSpeed: Float?
//            "windGust": 21.55,
            let windGust: Float?
//            "windBearing": 295,
            let windBearing: Float?
//            "cloudCover": 0.03,
            let cloudCover: Float?
//            "uvIndex": 0,
            let uvIndex: Float?
//            "visibility": 8.32,
            let visibility: Float?
//            "ozone": 321.6
            let ozone: Float?
        }

//         "latitude": 59.3310373,

        let latitude: Double
//         "longitude": 18.0706638,
        let longitude: Double
//        "timezone": "Europe/Stockholm",
        let timezone: String?
//        "currently":
        let currently: Weather
    }

    enum Error: Swift.Error {
        case noData
        case network(error: Swift.Error)
        case decoding(error: Swift.Error)
    }
}

protocol WeatherApiService {
    func fetch(request: WeatherApi.Request, completion: @escaping (Result<WeatherApi.Response, WeatherApi.Error>) -> Void)
}

final class WeatherApiServiceMock: WeatherApiService {
    func fetch(request: WeatherApi.Request, completion: @escaping (Result<WeatherApi.Response, WeatherApi.Error>) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            completion(
                .success(WeatherApi.Response(
                            latitude: 50,
                            longitude: 50,
                            timezone: nil,
                            currently: WeatherApi.Response.Weather(
                                time: Date().timeIntervalSince1970,
                                summary: "Clear",
                                icon: nil,
                                precipIntensity: 0,
                                precipProbability: 0,
                                temperature: 27.5,
                                apparentTemperature: 27.5,
                                dewPoint: 0,
                                humidity: 13,
                                pressure: 1017.2,
                                windSpeed: 1.2,
                                windGust: 2,
                                windBearing: 123,
                                cloudCover: 0,
                                uvIndex: 0,
                                visibility: 50,
                                ozone: 0))))
        }
    }
}

final class WeatherApiServiceImpl: WeatherApiService {
    func fetch(request: WeatherApi.Request, completion: @escaping (Result<WeatherApi.Response, WeatherApi.Error>) -> Void) {
        let url = URL(string: "https://api.darksky.net/forecast/2bb07c3bece89caf533ac9a5d23d8417/\(request.location.latitude),\(request.location.longitude)?units=si")
        let task = URLSession.shared.dataTask(with: url!) { data, _, error in
            guard let data = data else {
                completion(.failure(.noData))
                return
            }
            if let error = error {
                completion(.failure(.network(error: error)))
                return
            }
            do {
                let response = try JSONDecoder().decode(WeatherApi.Response.self, from: data)
                completion(.success(response))
            } catch {
                completion(.failure(.decoding(error: error)))
            }
        }
        task.resume()
    }
}
