//
//  RootInteractor.swift
//  WeatherApp
//
//  Created by sahey on 14.02.2021.
//

import Combine

protocol RootInteractor {
    func startApp()
}

protocol RootDeeplinkable: AnyObject {
    func openTabBar() -> AnyPublisher<TabBarDeeplinkable, Never>
}

final class RootInteractorImpl: RootInteractor {
    private let router: RootRouter
    private var tabBarDeeplinkable: TabBarDeeplinkable?

    init(router: RootRouter) {
        self.router = router
    }

    @discardableResult
    private func startTabBar() -> TabBarDeeplinkable {
        let deeplinkable = router.routeToTabBar()
        tabBarDeeplinkable = deeplinkable
        return deeplinkable
    }

    func startApp() {
        // some onboarding or login scenario could be added
        startTabBar()
    }
}

extension RootInteractorImpl: RootDeeplinkable {
    func openTabBar() -> AnyPublisher<TabBarDeeplinkable, Never> {
        guard let tabBarDeeplinkable = tabBarDeeplinkable else {
            return Just(startTabBar()).eraseToAnyPublisher()
        }
        return Just(tabBarDeeplinkable).eraseToAnyPublisher()
    }
}
