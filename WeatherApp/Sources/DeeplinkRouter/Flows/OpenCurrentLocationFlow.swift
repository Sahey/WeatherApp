//
//  SearchFlow.swift
//  WeatherApp
//
//  Created by s.ignatyev on 26.02.2021.
//

class OpenCurrentLocationFlow: DeeplinkFlow<RootDeeplinkable> {
    override init() {
        super.init()
        onStep { root in
            root.openTabBar()
        }
        .onStep { tabBar in
            tabBar.openWeather()
        }
        .commit()
    }
}
