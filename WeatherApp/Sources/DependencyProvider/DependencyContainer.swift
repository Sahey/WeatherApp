//
//  DependencyProvider.swift
//  WeatherApp
//
//  Created by sahey on 13.02.2021.
//

import Foundation

typealias DependencyFactory<Dependency> = (DependencyContainer) -> Dependency

protocol DependencyContainer {
    func register<Dependency>(_ type: Dependency.Type, name: String, factory: @escaping DependencyFactory<Dependency>)
    func register<Dependency>(_ type: Dependency.Type, factory: @escaping DependencyFactory<Dependency>)
    func resolve<Dependency>(_ type: Dependency.Type, name: String) -> Dependency?
    func resolve<Dependency>(_ type: Dependency.Type) -> Dependency?
}

protocol DependencyStorage: AnyObject {
    func dependency(key: String) -> Any?
    func set(dependency: Any, for: String)
}

// MARK: - Container

final class DependencyContainerImpl {
    private var storage: DependencyStorage

    init(storage: DependencyStorage = DependencyStorageImpl()) {
        self.storage = storage
    }
}

extension DependencyContainerImpl: DependencyContainer {
    private func getKey<Dependency>(for type: Dependency.Type, name: String?) -> String {
        let typeDescription = String(describing: type)
        guard let name = name, !name.isEmpty else { return typeDescription }
        return typeDescription + "_" + name
    }

    func register<Dependency>(_ type: Dependency.Type, name: String, factory: @escaping DependencyFactory<Dependency>) {
        let key = getKey(for: type, name: name)
        let value = factory(self)
        storage.set(dependency: value, for: key)
    }

    func register<Dependency>(_ type: Dependency.Type, factory: @escaping DependencyFactory<Dependency>) {
        register(type, name: "", factory: factory)
    }

    func resolve<Dependency>(_ type: Dependency.Type, name: String) -> Dependency? {
        let key = getKey(for: type, name: name)
        return storage.dependency(key: key) as? Dependency
    }

    func resolve<Dependency>(_ type: Dependency.Type) -> Dependency? {
        resolve(type, name: "")
    }
}

// MARK: - Storage

final class DependencyStorageImpl: DependencyStorage {
    private var dictionary: [String: Any] = [:]
    private let queue = DispatchQueue(
        label: "dependency.storage.queue",
        qos: .userInitiated,
        attributes: [.concurrent]
    )

    func dependency(key: String) -> Any? {
        queue.sync {
            dictionary[key]
        }
    }

    func set(dependency: Any, for key: String) {
        queue.async(flags: .barrier) {
            self.dictionary[key] = dependency
        }
    }
}
