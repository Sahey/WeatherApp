//
//  DeeplinkRouter.swift
//  WeatherApp
//
//  Created by sahey on 15.02.2021.
//

import Combine
import CoreLocation
import Foundation

// MARK: - Flows

final class OpenForecastFlow: DeeplinkFlow<RootDeeplinkable> {
    struct Input {
        let name: String?
        let location: CLLocationCoordinate2D
    }

    init(input: Input) {
        super.init()
        onStep { root in
            root.openTabBar()
        }
        .onStep { tabBar in
            tabBar.openSearch()
        }
        .onStep { search in
            search.openWeather(input: input)
        }
        .commit()
    }
}

final class SearchForecastFlow: DeeplinkFlow<RootDeeplinkable> {
    struct Input {
        let query: String?
    }

    init(input: Input) {
        super.init()
        onStep { root in
            root.openTabBar()
        }
        .onStep { tabBar in
            tabBar.openSearch()
        }
        .onStep { search in
            search.searchForecast(input: input)
        }
        .commit()
    }
}

// MARK: - Router

protocol DeeplinkRouter {
    func route(url: URL)
}

enum Deeplink: String {
    case openForecast
    case search
}

final class DeeplinkRouterImpl {
    enum Flow {
        case openForecast(flow: OpenForecastFlow)
        case searchForecast(flow: SearchForecastFlow)
    }

    private var subscribtions: Set<AnyCancellable>?
    private let root: RootDeeplinkable

    init(root: RootDeeplinkable) {
        self.root = root
    }

    private func createFlow(url: URL) -> Flow? {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let host = components.host else { return nil }
        var parameters = [String: String]()
        components.queryItems?.forEach {
            parameters[$0.name] = $0.value
        }
        switch host {
        case .openForecast:
            guard let latStr = parameters["lat"],
                  let lonStr = parameters["lon"],
                  let lat = Double(latStr),
                  let lon = Double(lonStr) else { return nil }
            let input = OpenForecastFlow.Input(
                name: parameters["name"],
                location: CLLocationCoordinate2D(
                    latitude: lat,
                    longitude: lon
                )
            )
            return .openForecast(
                flow: OpenForecastFlow(input: input)
            )
        case .search:
            return .searchForecast(
                flow: SearchForecastFlow(
                    input: SearchForecastFlow.Input(
                        query: parameters["query"]
                    )
                )
            )
        default:
            return nil
        }
    }
}

extension DeeplinkRouterImpl: DeeplinkRouter {
    func route(url: URL) {
        switch createFlow(url: url) {
        case let .openForecast(flow):
            subscribtions = flow.subcscribe(root)
        case let .searchForecast(flow):
            subscribtions = flow.subcscribe(root)
        case .none: ()
        }
    }
}

private extension String {
    static var openForecast: String { "openForecast" }
    static var search: String { "search" }
}
