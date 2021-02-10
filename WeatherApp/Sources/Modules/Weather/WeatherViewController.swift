//
//  WeatherViewController.swift
//  WeatherApp
//
//  Created by sahey on 11.02.2021.
//

import UIKit

protocol WeatherDisplayLogic: AnyObject {
    func display(isLoading: Bool)
    func display(viewModel: Weather.ViewModel)
}

final class WeatherViewController: UIViewController {
    private typealias TemperatureCell = TableViewCell<TemperatureView>
    private typealias IndicatorCell = TableViewCell<WeatherIndicatorView>

    var interactor: WeatherInteractor?

    private var sections: [Weather.ViewModel.Section] = []

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        tableView.register(TemperatureCell.self)
        tableView.register(IndicatorCell.self)
        return tableView
    }()

    private let activityIndicatorView: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView()
        activityIndicatorView.hidesWhenStopped = true
        return activityIndicatorView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        interactor?.didLoadView()
    }

    private func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupActivityIndicatorView() {
        view.addSubview(activityIndicatorView)
        activityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicatorView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicatorView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setup() {
        view.backgroundColor = .background
        setupTableView()
        setupActivityIndicatorView()
    }

    private func display(viewModel: Weather.ViewModel.NetworkAlert) {
        let alertController = UIAlertController(title: viewModel.title, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: viewModel.retry, style: .default, handler: { _ in
            self.interactor?.didTapRetry()
        }))
        present(alertController, animated: true)
    }

    @objc private func willEnterForeground() {
        NotificationCenter.default.removeObserver(self)
        interactor?.willEnterForeground()
    }

    private func display(viewModel: Weather.ViewModel.PermissionAlert) {
        let alertController = UIAlertController(title: viewModel.title, message: nil, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: viewModel.openSettings, style: .default, handler: { _ in
            NotificationCenter.default.addObserver(self, selector: #selector(self.willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
            self.interactor?.didTapSettings()
        }))
        alertController.addAction(UIAlertAction(title: viewModel.cancel, style: .cancel, handler: { _ in
            self.interactor?.didTapPermissionCancel()
        }))
        present(alertController, animated: true)
    }
}

extension WeatherViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = sections[indexPath.section].items[indexPath.row]
        switch item {
        case let .temperature(viewModel):
            let cell = tableView.dequeue(TemperatureCell.self, for: indexPath)
            cell.wrappedView.configure(viewModel)
            return cell
        case let .indicator(viewModel):
            let cell = tableView.dequeue(IndicatorCell.self, for: indexPath)
            cell.wrappedView.configure(viewModel)
            return cell
        }
    }
}

extension WeatherViewController: WeatherDisplayLogic {
    func display(isLoading: Bool) {
        if isLoading {
            activityIndicatorView.startAnimating()
        } else {
            activityIndicatorView.stopAnimating()
        }
    }

    func display(viewModel: Weather.ViewModel) {
        switch viewModel {
        case let .weather(data):
            sections = data.section
            tableView.reloadData()
        case let .error(alert):
            display(viewModel: alert)
        case let .permission(alert):
            display(viewModel: alert)
        }
    }
}
