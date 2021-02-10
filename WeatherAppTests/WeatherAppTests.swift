//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by sahey on 11.02.2021.
//

@testable import WeatherApp
import XCTest

final class WeatherPresenterMock: WeatherPresenter {
    var presentResponseCallsCount = 0
    var presentResponseReceivedResponse: Weather.Response?

    func present(response: Weather.Response) {
        presentResponseCallsCount += 1
        presentResponseReceivedResponse = response
    }

    var presentErrorCallsCount = 0
    var presentErrorReceivedError: Weather.Error?

    func present(error: Weather.Error) {
        presentErrorCallsCount += 1
        presentErrorReceivedError = error
    }

    var presentIsLoadingCount = 0
    var presentIsLoadingReceivedIsLoading: Bool?

    func present(isLoading: Bool) {
        presentIsLoadingCount += 1
        presentIsLoadingReceivedIsLoading = isLoading
    }
}

final class WeatherRouterMock: WeatherRouter {
    var routeToSettingsCallsCount = 0

    func routeToSettings() {
        routeToSettingsCallsCount += 1
    }
}

final class WeatherRepositoryMock: WeatherRepository {
    var requestDataRequestCallsCount = 0
    var requestDataRequestReceivedRequest: Weather.Request?
    var requestDataRequestCompletionClosure: ((Weather.Request, @escaping (Result<Weather.Response, Weather.Error>) -> Void) -> Void)?

    func requestData(request: Weather.Request, completion: @escaping (Result<Weather.Response, Weather.Error>) -> Void) {
        requestDataRequestCallsCount += 1
        requestDataRequestReceivedRequest = request
        requestDataRequestCompletionClosure?(request, completion)
    }

    var requestDataRequestDefaultCallsCount = 0
    var requestDataRequestDefaultReceivedRequest: Weather.RequestDefault?
    var requestDataRequestDefaultCompletionClosure: ((Weather.RequestDefault, @escaping (Result<Weather.Response, Weather.Error>) -> Void) -> Void)?

    func requestData(request: Weather.RequestDefault, completion: @escaping (Result<Weather.Response, Weather.Error>) -> Void) {
        requestDataRequestDefaultCallsCount += 1
        requestDataRequestDefaultReceivedRequest = request
        requestDataRequestDefaultCompletionClosure?(request, completion)
    }
}

class WeatherAppTests: XCTestCase {
    private var subject: WeatherInteractorImpl!
    private var presenter: WeatherPresenterMock!
    private var router: WeatherRouterMock!
    private var repository: WeatherRepositoryMock!
    private var response: Weather.Response!
    private var error: Weather.Error!

    override func setUp() {
        super.setUp()
        presenter = WeatherPresenterMock()
        router = WeatherRouterMock()
        repository = WeatherRepositoryMock()
        subject = WeatherInteractorImpl(presenter: presenter, router: router, repository: repository)
        response = nil
        error = nil
    }

    func testDidLoadViewSuccess() throws {
        // given
        response = .test
        repository.requestDataRequestCompletionClosure = {
            $1(.success(self.response))
        }
        // when
        subject.didLoadView()
        // then
        XCTAssertEqual(presenter.presentIsLoadingCount, 2, "is loading should be called twice")
        XCTAssertEqual(repository.requestDataRequestCallsCount, 1, "data should be requested")
        XCTAssertNil(repository.requestDataRequestReceivedRequest?.location, "on initial request location should be unknown")
        XCTAssertEqual(presenter.presentErrorCallsCount, 0, "error should not be presented on success case")
        XCTAssertEqual(presenter.presentResponseCallsCount, 1, "data should be presented")
        XCTAssertEqual(presenter.presentResponseReceivedResponse, response, "data should be valid")
    }

    func testDidLoadViewFailure() throws {
        // given
        error = .noData
        repository.requestDataRequestCompletionClosure = {
            $1(.failure(self.error))
        }
        // when
        subject.didLoadView()
        // then
        XCTAssertEqual(presenter.presentIsLoadingCount, 2, "is loading should be called twice")
        XCTAssertEqual(repository.requestDataRequestCallsCount, 1, "data should be requested")
        XCTAssertNil(repository.requestDataRequestReceivedRequest?.location, "on initial request location should be unknown")
        XCTAssertEqual(presenter.presentErrorCallsCount, 1, "error should be presented on failure case")
        XCTAssertEqual(presenter.presentResponseCallsCount, 0, "data should not be presented")
    }

    func testDidTapRetrySuccess() throws {
        // given
        response = .test
        repository.requestDataRequestCompletionClosure = {
            $1(.success(self.response))
        }
        // when
        subject.didTapRetry()
        // then
        XCTAssertEqual(presenter.presentIsLoadingCount, 2, "is loading should be called twice")
        XCTAssertEqual(repository.requestDataRequestCallsCount, 1, "data should be requested")
        XCTAssertNil(repository.requestDataRequestReceivedRequest?.location, "on retry request location should be unknown")
        XCTAssertEqual(presenter.presentErrorCallsCount, 0, "error should not be presented on success case")
        XCTAssertEqual(presenter.presentResponseCallsCount, 1, "data should be presented")
        XCTAssertEqual(presenter.presentResponseReceivedResponse, response, "data should be valid")
    }

    func testDidTapRetryFailure() throws {
        // given
        error = .noData
        repository.requestDataRequestCompletionClosure = {
            $1(.failure(self.error))
        }
        // when
        subject.didTapRetry()
        // then
        XCTAssertEqual(presenter.presentIsLoadingCount, 2, "is loading should be called twice")
        XCTAssertEqual(repository.requestDataRequestCallsCount, 1, "data should be requested")
        XCTAssertNil(repository.requestDataRequestReceivedRequest?.location, "on retry request location should be unknown")
        XCTAssertEqual(presenter.presentErrorCallsCount, 1, "error should be presented on failure case")
        XCTAssertEqual(presenter.presentResponseCallsCount, 0, "data should not be presented")
    }

    func testDidTapPermissionCancelSuccess() throws {
        // given
        response = .test
        repository.requestDataRequestCompletionClosure = {
            $1(.success(self.response))
        }
        // when
        subject.didTapPermissionCancel()
        // then
        XCTAssertEqual(presenter.presentIsLoadingCount, 2, "is loading should be called twice")
        XCTAssertEqual(repository.requestDataRequestCallsCount, 1, "data should be requested")
        XCTAssertNotNil(repository.requestDataRequestReceivedRequest?.location, "defaul location should be used")
        XCTAssertEqual(presenter.presentErrorCallsCount, 0, "error should not be presented on success case")
        XCTAssertEqual(presenter.presentResponseCallsCount, 1, "data should be presented")
        XCTAssertEqual(presenter.presentResponseReceivedResponse, response, "data should be valid")
    }

    func testDidTapPermissionCancelFailure() throws {
        // given
        error = .noData
        repository.requestDataRequestCompletionClosure = {
            $1(.failure(self.error))
        }
        // when
        subject.didTapPermissionCancel()
        // then
        XCTAssertEqual(presenter.presentIsLoadingCount, 2, "is loading should be called twice")
        XCTAssertEqual(repository.requestDataRequestCallsCount, 1, "data should be requested")
        XCTAssertNotNil(repository.requestDataRequestReceivedRequest?.location, "defaul location should be used")
        XCTAssertEqual(presenter.presentErrorCallsCount, 1, "error should be presented on failure case")
        XCTAssertEqual(presenter.presentResponseCallsCount, 0, "data should not be presented")
    }

    func testDidTapSettings() throws {
        // given
        // when
        subject.didTapSettings()
        // then
        XCTAssertEqual(presenter.presentIsLoadingCount, 0, "is loading should not be called")
        XCTAssertEqual(repository.requestDataRequestCallsCount, 0, "data should not be requested")
        XCTAssertEqual(presenter.presentErrorCallsCount, 0, "error should not be presented")
        XCTAssertEqual(presenter.presentResponseCallsCount, 0, "data should not be presented")
        XCTAssertEqual(router.routeToSettingsCallsCount, 1, "should route to settings")
    }

    func testWillEnterForegroundSuccess() throws {
        // given
        response = .test
        repository.requestDataRequestDefaultCompletionClosure = {
            $1(.success(self.response))
        }
        // when
        subject.willEnterForeground()
        // then
        XCTAssertEqual(presenter.presentIsLoadingCount, 2, "is loading should be called twice")
        XCTAssertEqual(repository.requestDataRequestDefaultCallsCount, 1, "data should be requested")
        XCTAssertEqual(presenter.presentErrorCallsCount, 0, "error should not be presented on success case")
        XCTAssertEqual(presenter.presentResponseCallsCount, 1, "data should be presented")
        XCTAssertEqual(presenter.presentResponseReceivedResponse, response, "data should be valid")
    }

    func testWillEnterForegroundFailure() throws {
        // given
        error = .noData
        repository.requestDataRequestDefaultCompletionClosure = {
            $1(.failure(self.error))
        }
        // when
        subject.willEnterForeground()
        // then
        XCTAssertEqual(presenter.presentIsLoadingCount, 2, "is loading should be called twice")
        XCTAssertEqual(repository.requestDataRequestDefaultCallsCount, 1, "data should be requested")
        XCTAssertEqual(presenter.presentErrorCallsCount, 1, "error should be presented")
        XCTAssertEqual(presenter.presentResponseCallsCount, 0, "data should not be presented on failure case")
    }
}

private extension Weather.Response {
    static var test: Weather.Response {
        Weather.Response(temperature: .random(in: 0...100),
                         summary: UUID().uuidString,
                         feelsLikeTemperature: .random(in: 0...100),
                         preciptation: Preciptation(
                             intensity: .random(in: 0...100),
                             probability: .random(in: 0...100)),
                         humidity: .random(in: 0...100),
                         wind: Wind(
                             speed: .random(in: 0...100),
                             gust: .random(in: 0...100),
                             bearing: .random(in: 0...100)),
                         visibility: .random(in: 0...100),
                         uvIndex: .random(in: 0...100),
                         pressure: .random(in: 0...100))
    }
}
