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
        let query: String
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
        if url.absoluteString.contains("openForecast") {
            return .openForecast(
                flow: OpenForecastFlow(
                    input: OpenForecastFlow.Input(
                        name: "🥶🥶🥶",
                        location: CLLocationCoordinate2D(latitude: 63.463446, longitude: 142.769950)
                    )
                )
            )
        } else if url.absoluteString.contains("searchForecast") {
            return .searchForecast(
                flow: SearchForecastFlow(
                    input: SearchForecastFlow.Input(query: "Stockholm")
                )
            )
        }
        return nil
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
