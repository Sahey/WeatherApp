//
//  TemperatureView.swift
//  WeatherApp
//
//  Created by sahey on 11.02.2021.
//

import UIKit

struct TemperatureViewModel {
    let temperature: String
    let info: String?
}

final class TemperatureView: UIView {
    @IBOutlet private var temperatureLabel: UILabel!
    @IBOutlet private var infoLabel: UILabel!

    func configure(_ viewModel: TemperatureViewModel) {
        temperatureLabel.text = viewModel.temperature
        infoLabel.text = viewModel.info
    }
}
