//
//  WeatherRouter.swift
//  WeatherApp
//
//  Created by sahey on 11.02.2021.
//

import UIKit

protocol WeatherRouter {
    func routeToSettings()
}

final class WeatherRouterImpl: WeatherRouter {
    func routeToSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
