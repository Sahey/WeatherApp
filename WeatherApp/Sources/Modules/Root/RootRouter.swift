//
//  RootRouter.swift
//  WeatherApp
//
//  Created by sahey on 14.02.2021.
//

import UIKit

protocol RootRouter {
    func routeToTabBar() -> TabBarDeeplinkable
}

final class RootRouterImpl: RootRouter {
    private let window: UIWindow
    private let tabBarBuilder: TabBarBuilder

    init(window: UIWindow, tabBarBuilder: TabBarBuilder) {
        self.window = window
        self.tabBarBuilder = tabBarBuilder
    }

    func routeToTabBar() -> TabBarDeeplinkable {
        let tabBar = tabBarBuilder.build()
        window.rootViewController = tabBar
        window.makeKeyAndVisible()
        return tabBar
    }
}
