//
//  DeeplinkTests.swift
//  WeatherAppTests
//
//  Created by sahey on 14.02.2021.
//

import Combine
import CoreLocation
@testable import WeatherApp
import XCTest

// MARK: Deeplinkable protocols

protocol SearchLocationDeeplinkable: AnyObject {
    func open(location: CLLocationCoordinate2D) -> AnyPublisher<SearchLocationDeeplinkable, Never>
}

protocol TabbarDeeplinkable: AnyObject {
    func openCurrentLocationWeather() -> AnyPublisher<TabbarDeeplinkable, Never>
    func openSearchLocation() -> AnyPublisher<SearchLocationDeeplinkable, Never>
}

// MARK: Abstract modules

open class Module {
    var children: [Module]
    var onVisit: (() -> Void)?
    init(_ children: [Module] = []) {
        self.children = children
    }

    func findChild<Child: Module>() -> Child? {
        children.first(where: { $0 is Child }) as? Child
    }
}

final class Tabbar: Module, TabbarDeeplinkable {
    func openCurrentLocationWeather() -> AnyPublisher<TabbarDeeplinkable, Never> {
        guard let module: CurrentLocationWeather = findChild() else {
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
        module.onVisit?()
        return Just(self)
            .eraseToAnyPublisher()
    }

    func openSearchLocation() -> AnyPublisher<SearchLocationDeeplinkable, Never> {
        guard let module: SearchLocation = findChild() else {
            return Empty(completeImmediately: true).eraseToAnyPublisher()
        }
        module.onVisit?()
        return Just(module)
            .eraseToAnyPublisher()
    }
}

final class CurrentLocationWeather: Module {}

final class SearchLocation: Module, SearchLocationDeeplinkable {
    private let passthrougObject = PassthroughSubject<SearchLocationDeeplinkable, Never>()

    func open(location: CLLocationCoordinate2D) -> AnyPublisher<SearchLocationDeeplinkable, Never> {
        if let module: WeatherForCoordinate = findChild() {
            // simluate async delay, could be network request or any other async event
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                module.receiveCoordinate = location
                module.onVisit?()
                self.passthrougObject.send(self)
            }
        }
        return passthrougObject
            .eraseToAnyPublisher()
    }
}

final class WeatherForCoordinate: Module {
    var receiveCoordinate: CLLocationCoordinate2D?
}

// MARK: Flows

final class DeeplinkWeather: DeeplinkFlow<Tabbar> {
    init(location: CLLocationCoordinate2D) {
        super.init()
        onStep { deeplink in
            deeplink.openSearchLocation()
        }
        .onStep { deeplink in
            deeplink.open(location: location)
        }
        .commit()
    }
}

class DeeplinkTests: XCTestCase {
    private var subject: DeeplinkWeather!

    private var tabbar: Tabbar!
    private var currentLocationWeather: CurrentLocationWeather!
    private var searchLocation: SearchLocation!
    private var weather: WeatherForCoordinate!
    private var location: CLLocationCoordinate2D!
    private var subscribtion: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        location = .random
        weather = WeatherForCoordinate()
        searchLocation = SearchLocation([weather])
        currentLocationWeather = CurrentLocationWeather()
        tabbar = Tabbar([
            currentLocationWeather,
            searchLocation
        ])
    }

    func testExample() throws {
        // given
        let deeplinkExpectation = expectation(description: "Deeplinking to location")
        weather.onVisit = {
            deeplinkExpectation.fulfill()
            XCTAssertNotNil(self.weather.receiveCoordinate, "should pass coordinate")
        }
        subject = DeeplinkWeather(location: location)
        // when
        subscribtion = subject.subcscribe(tabbar)
        // then
        waitForExpectations(timeout: 1, handler: nil)
    }
}

extension CLLocationCoordinate2D {
    static var random: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: Double.random(in: -90...90), longitude: Double.random(in: -180...180))
    }
}
