//
//  WeatherInfoView.swift
//  WeatherApp
//
//  Created by sahey on 11.02.2021.
//

import UIKit

struct WeatherIndicatorViewModel {
    let title: String
    let value: String
}

final class WeatherIndicatorView: UIView {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!

    func configure(_ viewModel: WeatherIndicatorViewModel) {
        titleLabel.text = viewModel.title
        valueLabel.text = viewModel.value
    }
}
