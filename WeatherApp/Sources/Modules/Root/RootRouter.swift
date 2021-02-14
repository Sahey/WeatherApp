//
//  RootRouter.swift
//  WeatherApp
//
//  Created by sahey on 14.02.2021.
//

import UIKit

protocol RootRouter {
    func routeToTabBar()
}

final class RootRouterImpl: RootRouter {
    private let window: UIWindow
    private let tabBarBuilder: TabBarBuilder

    init(window: UIWindow, tabBarBuilder: TabBarBuilder) {
        self.window = window
        self.tabBarBuilder = tabBarBuilder
    }

    func routeToTabBar() {
        window.rootViewController = tabBarBuilder.build()
        window.makeKeyAndVisible()
    }
}
