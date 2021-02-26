//
//  SearchFlow.swift
//  WeatherApp
//
//  Created by s.ignatyev on 26.02.2021.
//

import CoreLocation

class SearchFlow: DeeplinkFlow<RootDeeplinkable> {
    override init() {
        super.init()
        onStep { root in
            root.openTabBar()
        }
        .onStep { tabBar in
            tabBar.openSearch()
        }
        .commit()
    }
}

final class OpenForecastFlow: DeeplinkFlow<RootDeeplinkable> {
    struct Input {
        let name: String?
        let location: CLLocationCoordinate2D
    }

    init(input: Input) {
        super.init()
        onStep { root in
            root.openTabBar()
        }
        .onStep { tabBar in
            tabBar.openSearch()
        }
        .onStep { search in
            search.openWeather(input: input)
        }
        .commit()
    }
}
