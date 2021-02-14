//
//  RootInteractor.swift
//  WeatherApp
//
//  Created by sahey on 14.02.2021.
//

protocol RootInteractor {
    func startApp()
}

final class RootInteractorImpl: RootInteractor {
    private let router: RootRouter

    init(router: RootRouter) {
        self.router = router
    }

    func startApp() {
        // some onboarding or login scenario could be added
        router.routeToTabBar()
    }
}
