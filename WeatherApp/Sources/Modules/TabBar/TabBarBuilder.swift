//
//  TabBarBuilder.swift
//  WeatherApp
//
//  Created by sahey on 14.02.2021.
//

import UIKit

protocol TabBarBuilder {
    func build() -> UIViewController
}

final class TabBarBuilderImpl: TabBarBuilder {
    private let weatherBuilder: WeatherBuilder
    private let searchBuilder: SearchBuilder

    private var viewControllers: [UIViewController] {
        [
            UINavigationController(rootViewController: weatherBuilder.build(input: .default).title("Current location forecast"))
                .tabBarItem(UITabBarItem(title: nil, image: UIImage(systemName: "cloud.sun.rain"), tag: 0)),
            searchBuilder.build().tabBarItem(UITabBarItem(title: nil, image: UIImage(systemName: "magnifyingglass"), tag: 1))
        ]
    }

    init(weatherBuilder: WeatherBuilder, searchBuilder: SearchBuilder) {
        self.weatherBuilder = weatherBuilder
        self.searchBuilder = searchBuilder
    }

    func build() -> UIViewController {
        let tabBarViewController = UITabBarController(nibName: nil, bundle: nil)
        tabBarViewController.viewControllers = viewControllers
        return tabBarViewController
    }
}
