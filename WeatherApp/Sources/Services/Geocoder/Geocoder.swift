//
//  Geocoder.swift
//  WeatherApp
//
//  Created by sahey on 14.02.2021.
//

import CoreLocation

protocol Geocoder {
    func geocodeAddressString(_ addressString: String, in region: CLRegion?, preferredLocale locale: Locale?, completionHandler: @escaping CLGeocodeCompletionHandler)
}

extension CLGeocoder: Geocoder {}
