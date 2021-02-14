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

    private var viewControllers: [UIViewController] {
        [
            weatherBuilder.build().tabBarItem(UITabBarItem(title: nil, image: UIImage(systemName: "cloud.sun.rain"), tag: 0))
        ]
    }

    init(weatherBuilder: WeatherBuilder) {
        self.weatherBuilder = weatherBuilder
    }

    func build() -> UIViewController {
        let tabBarViewController = UITabBarController(nibName: nil, bundle: nil)
        tabBarViewController.viewControllers = viewControllers
        return tabBarViewController
    }
}
