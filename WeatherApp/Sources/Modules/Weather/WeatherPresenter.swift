//
//  WeatherPresenter.swift
//  WeatherApp
//
//  Created by sahey on 11.02.2021.
//

import Foundation

protocol WeatherPresenter: AnyObject {
    func present(response: Weather.Response)
    func present(error: Weather.Error)
    func present(isLoading: Bool)
}

final class WeatherPresenterImpl {
    typealias ViewModel = Weather.ViewModel
    typealias Item = Weather.ViewModel.Item
    typealias Section = Weather.ViewModel.Section

    private weak var view: WeatherDisplayLogic?
    private let measurementFormatter: MeasurementFormatter = {
        let formatter = MeasurementFormatter()
        formatter.unitOptions = .providedUnit
        formatter.unitStyle = .medium
        return formatter
    }()

    private let numberFormatter = NumberFormatter()

    init(view: WeatherDisplayLogic) {
        self.view = view
    }

    private func createPrettyMeasurement(_ value: Float, unit: Dimension) -> String {
        let value = Measurement(value: Double(value), unit: unit)
        return measurementFormatter.string(from: value)
    }

    private func createPrettyNumber(_ number: Float) -> String {
        numberFormatter.numberStyle = .decimal
        numberFormatter.maximumFractionDigits = 2
        return numberFormatter.string(from: NSNumber(value: number)) ?? String(number)
    }

    private func createPrettyPercents(_ number: Float) -> String {
        numberFormatter.numberStyle = .percent
        return numberFormatter.string(from: NSNumber(value: number)) ?? String(number)
    }

    private func createViewModel(response: Weather.Response) -> ViewModel.Weather {
        let sections: [Section?] = [
            createMainSection(response: response),
            createWindViewModel(response: response),
            createPreciptationViewModel(response: response),
            createOtherIndicatorViewModel(response: response)
        ]

        return ViewModel.Weather(section: sections.compactMap { $0 })
    }
}

extension WeatherPresenterImpl {
    // MARK: - Temperature

    private func createTemperatureViewModel(response: Weather.Response) -> TemperatureViewModel {
        return TemperatureViewModel(
            temperature: createPrettyMeasurement(response.temperature, unit: UnitTemperature.celsius),
            info: response.summary
        )
    }

    private func createMainSection(response: Weather.Response) -> Section {
        var items: [Item] = [
            .temperature(viewModel: createTemperatureViewModel(response: response))
        ]
        if let feelsLike = response.feelsLikeTemperature {
            let temperature = Measurement(value: Double(feelsLike), unit: UnitTemperature.celsius)
            let prettyTemperature = measurementFormatter.string(from: temperature)
            items.append(.indicator(viewModel: WeatherIndicatorViewModel(
                title: "Feels like",
                value: prettyTemperature
            )))
        }
        return Section(items: items)
    }

    // MARK: - Preciptation

    private func createPreciptationViewModel(response: Weather.Response) -> Section? {
        guard let preciptation = response.preciptation else { return nil }
        return Section(items: [
            .indicator(viewModel: WeatherIndicatorViewModel(
                title: "Preciptation intensity",
                value: createPrettyMeasurement(preciptation.intensity, unit: UnitLength.centimeters)
            )),
            .indicator(viewModel: WeatherIndicatorViewModel(
                title: "Preciptation probability",
                value: createPrettyPercents(preciptation.probability)
            ))
        ])
    }

    // MARK: - Wind

    private func createWindViewModel(response: Weather.Response) -> Section? {
        guard let wind = response.wind else { return nil }
        return Section(items: [
            .indicator(viewModel: WeatherIndicatorViewModel(
                title: "Wind speed",
                value: createPrettyMeasurement(wind.speed, unit: UnitSpeed.metersPerSecond)
            )),
            .indicator(viewModel: WeatherIndicatorViewModel(
                title: "Wind bearing",
                value: createPrettyMeasurement(wind.bearing, unit: UnitAngle.degrees)
            )),
            .indicator(viewModel: WeatherIndicatorViewModel(
                title: "Wind gust",
                value: createPrettyMeasurement(wind.gust, unit: UnitSpeed.metersPerSecond)
            ))
        ])
    }

    // MARK: - Other

    private func createHumidity(response: Weather.Response) -> Item? {
        guard let humidity = response.humidity else { return nil }
        let viewModel = WeatherIndicatorViewModel(
            title: "Humidity",
            value: createPrettyPercents(humidity)
        )
        return .indicator(viewModel: viewModel)
    }

    private func createVisibility(response: Weather.Response) -> Item? {
        guard let visibility = response.visibility else { return nil }
        let viewModel = WeatherIndicatorViewModel(
            title: "Visibility",
            value: createPrettyMeasurement(visibility, unit: UnitLength.kilometers)
        )
        return .indicator(viewModel: viewModel)
    }

    private func createUvIndex(response: Weather.Response) -> Item? {
        guard let uvIndex = response.uvIndex else { return nil }
        let viewModel = WeatherIndicatorViewModel(
            title: "UV Index",
            value: createPrettyNumber(uvIndex)
        )
        return .indicator(viewModel: viewModel)
    }

    private func createPressure(response: Weather.Response) -> Item? {
        guard let pressure = response.pressure else { return nil }
        let viewModel = WeatherIndicatorViewModel(
            title: "Pressure",
            value: createPrettyMeasurement(pressure, unit: UnitPressure.millimetersOfMercury)
        )
        return .indicator(viewModel: viewModel)
    }

    private func createOtherIndicatorViewModel(response: Weather.Response) -> Section? {
        let items = [
            createHumidity(response: response),
            createVisibility(response: response),
            createPressure(response: response),
            createUvIndex(response: response)
        ]
        .compactMap { $0 }
        guard !items.isEmpty else {
            return nil
        }
        return Section(items: items)
    }
}

extension WeatherPresenterImpl: WeatherPresenter {
    func present(isLoading: Bool) {
        view?.display(isLoading: isLoading)
    }

    func present(response: Weather.Response) {
        let viewModel = createViewModel(response: response)
        view?.display(viewModel: .weather(data: viewModel))
    }

    func present(error: Weather.Error) {
        let viewModel: Weather.ViewModel
        switch error {
        case .locationPermissionDenied:
            viewModel = .permission(alert: Weather.ViewModel.PermissionAlert(title: "Please allow location permission in settings", openSettings: "Open settings", cancel: "No"))
        case let .network(error):
            viewModel = .error(alert: Weather.ViewModel.NetworkAlert(title: "Something went wrong: \(error.localizedDescription)", retry: "Retry"))
        case .noData:
            viewModel = .error(alert: Weather.ViewModel.NetworkAlert(title: "Something went wrong", retry: "Retry"))
        }
        view?.display(viewModel: viewModel)
    }
}
