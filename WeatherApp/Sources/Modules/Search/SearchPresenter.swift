//
//  SearchPresenter.swift
//  WeatherApp
//
//  Created by sahey on 14.02.2021.
//

protocol SearchPresenter {
    func present(response: Search.Response)
    func present(error: Search.Error)
}

final class SearchPresenterImpl: SearchPresenter {
    weak var view: SearchDisplayLogic?

    private func toViewModel(response: Search.Response.Place) -> Search.ViewModel.Item {
        Search.ViewModel.Item(
            idintifier: response.identifier,
            title: response.name,
            subtitle: response.country
        )
    }

    func present(error _: Search.Error) {
        view?.diplay(viewModel: Search.ViewModel(items: []))
    }

    func present(response: Search.Response) {
        view?.diplay(
            viewModel: Search.ViewModel(
                items: response.places.map(toViewModel)
            )
        )
    }
}
