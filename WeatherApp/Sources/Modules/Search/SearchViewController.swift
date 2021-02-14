//
//  SearchViewController.swift
//  WeatherApp
//
//  Created by sahey on 14.02.2021.
//

import UIKit

protocol SearchDisplayLogic: AnyObject {
    func diplay(viewModel: Search.ViewModel)
}

final class SearchViewController: UIViewController {
    private let interactor: SearchInteractor

    private var items: [Search.ViewModel.Item] = []
    private let cellIdentifier = String(describing: UITableViewCell.self)

    init(interactor: SearchInteractor) {
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()

    override func loadView() {
        view = tableView
        setup()
    }

    private func setup() {
        title = "Weather forecast"
        setupSearchController()
    }

    private func setupSearchController() {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.obscuresBackgroundDuringPresentation = false
        search.searchBar.placeholder = "Type location"
        navigationItem.searchController = search
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    private func dequeueCell(_ tableView: UITableView) -> UITableViewCell {
        let cell: UITableViewCell
        if let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) {
            cell = dequeuedCell
        } else {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        dequeueCell(tableView).configure(viewModel: items[indexPath.row])
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let identifier = items[indexPath.row].idintifier
        interactor.didSelectLocation(identifier: identifier)
    }
}

extension SearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        interactor.didSearch(query: text)
    }
}

extension SearchViewController: SearchDisplayLogic {
    func diplay(viewModel: Search.ViewModel) {
        items = viewModel.items
        tableView.reloadData()
    }
}

private extension UITableViewCell {
    func configure(viewModel: Search.ViewModel.Item) -> Self {
        textLabel?.text = viewModel.title
        detailTextLabel?.text = viewModel.subtitle
        return self
    }
}
