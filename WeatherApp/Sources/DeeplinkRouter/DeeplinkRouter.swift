//
//  DeeplinkRouter.swift
//  WeatherApp
//
//  Created by sahey on 15.02.2021.
//

import Combine
import CoreLocation
import Foundation

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
        case current(flow: OpenCurrentLocationFlow)
        case search(flow: SearchFlow)
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
        case .search:
            return .search(flow: SearchFlow())
        case .current:
            return .current(flow: OpenCurrentLocationFlow())
        default:
            return nil
        }
    }
}

extension DeeplinkRouterImpl: DeeplinkRouter {
    func route(url: URL) {
        switch createFlow(url: url) {
        case let .current(flow):
            subscribtions = flow.subcscribe(root)
        case let .search(flow):
            subscribtions = flow.subcscribe(root)
        case .none: ()
        }
    }
}

private extension String {
    //    weatherapp://current
    static var current: String { "current" }
    //    weatherapp://search
    static var search: String { "search" }
}
