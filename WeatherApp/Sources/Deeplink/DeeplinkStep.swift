//
//  DeeplinkStep.swift
//  WeatherApp
//
//  Created by sahey on 14.02.2021.
//

import Combine

open class DeeplinkStep<DeeplinkableFlow, Deeplinkable> {
    private let flow: DeeplinkFlow<DeeplinkableFlow>
    private let publisher: AnyPublisher<Deeplinkable, Never>

    init(flow: DeeplinkFlow<DeeplinkableFlow>, publisher: AnyPublisher<Deeplinkable, Never>) {
        self.flow = flow
        self.publisher = publisher
    }

    func onStep<NextDeeplinkHandler>(
        _ onStep: @escaping (Deeplinkable) -> AnyPublisher<NextDeeplinkHandler, Never>
    ) -> DeeplinkStep<DeeplinkableFlow, NextDeeplinkHandler> {
        let nextStepPublisher =
            publisher
                .flatMap { deeplink in
                    onStep(deeplink)
                }
                .eraseToAnyPublisher()
        return DeeplinkStep<DeeplinkableFlow, NextDeeplinkHandler>(flow: flow, publisher: nextStepPublisher)
    }

    @discardableResult
    final func commit() -> DeeplinkFlow<DeeplinkableFlow> {
        let cancelable = publisher.sink { _ in }
        flow.subscribtions.insert(cancelable)
        return flow
    }
}
