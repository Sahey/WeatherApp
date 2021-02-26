//
//  DeeplinkTestViewController.swift
//  WeatherApp
//
//  Created by s.ignatyev on 25.02.2021.
//

import UIKit

final class DeeplinkTestViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        let stackView = UIStackView(arrangedSubviews: [
            createButton(title: "Go to search", action: #selector(testSearch)),
            createButton(title: "Go to forecast", action: #selector(testForecast)),
        ])
        stackView.axis = .vertical
        stackView.spacing = 15
        stackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
        ])
    }

    func createButton(title: String, action: Selector) -> UIButton {
        let button = UIButton()
        button.heightAnchor.constraint(equalToConstant: 50).isActive = true
        button.setTitle(title, for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    @objc private func testSearch() {
        print("test search")
    }

    @objc private func testForecast() {
        print("test forecast")
    }

    private func open(_ link: String) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url, options: [:])
    }
}
