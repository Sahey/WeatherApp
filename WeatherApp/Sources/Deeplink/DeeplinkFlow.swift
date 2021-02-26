//
//  DeeplinkFlow.swift
//  WeatherApp
//
//  Created by Sahey on 14.02.2021.
//

import Combine

open class DeeplinkFlow<Deeplinkable> {
    private let subject = PassthroughSubject<Deeplinkable, Never>()
    var subscribtions = Set<AnyCancellable>()

    final func onStep<NextDeeplinkable>(
        _ onStep: @escaping (Deeplinkable) -> AnyPublisher<NextDeeplinkable, Never>
    ) -> DeeplinkStep<Deeplinkable, NextDeeplinkable> {
        DeeplinkStep(flow: self, publisher: subject.eraseToAnyPublisher())
            .onStep { deeplink in
                onStep(deeplink)
            }
    }

    func subcscribe(_ deeplinkHandler: Deeplinkable) -> Set<AnyCancellable> {
        subject.send(deeplinkHandler)
        return subscribtions
    }
}
