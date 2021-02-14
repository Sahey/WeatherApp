//
//  TabBarController.swift
//  WeatherApp
//
//  Created by sahey on 15.02.2021.
//

import Combine
import UIKit

protocol TabBarDeeplinkable {
    func openWeather() -> AnyPublisher<TabBarDeeplinkable, Never>
    func openSearch() -> AnyPublisher<SearchDeeplinkable, Never>
}

final class TabBarController: UITabBarController {
    private let weatherModule: UIViewController
    private let searchModule: UIViewController & SearchDeeplinkable

    init(weatherModule: UIViewController, searchModule: UIViewController & SearchDeeplinkable) {
        self.weatherModule = weatherModule
        self.searchModule = searchModule
        super.init(nibName: nil, bundle: nil)
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        viewControllers = [
            UINavigationController(rootViewController: weatherModule.title("Current location forecast"))
                .tabBarItem(UITabBarItem(title: nil, image: UIImage(systemName: "cloud.sun.rain"), tag: .weather)),
            UINavigationController(rootViewController: searchModule)
                .tabBarItem(UITabBarItem(title: nil, image: UIImage(systemName: "magnifyingglass"), tag: .search))
        ]
    }
}

extension TabBarController: TabBarDeeplinkable {
    func openWeather() -> AnyPublisher<TabBarDeeplinkable, Never> {
        selectedIndex = .weather
        return Just(self)
            .delay(for: 0.3, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }

    func openSearch() -> AnyPublisher<SearchDeeplinkable, Never> {
        selectedIndex = .search
        return Just(searchModule)
            .delay(for: 0.3, scheduler: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

private extension Int {
    static var weather: Int { 0 }
    static var search: Int { 1 }
}
