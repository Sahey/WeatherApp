//
//  DependencyContainerTests.swift
//  WeatherAppTests
//
//  Created by sahey on 13.02.2021.
//

@testable import WeatherApp
import XCTest

final class DependencyStorageMock: DependencyStorage {
    var dependencyKeyCallsCount = 0
    var dependencyKeyReceivedKey: String?
    var dependencyKeyReturnValue: Any?

    func dependency(key: String) -> Any? {
        dependencyKeyCallsCount += 1
        dependencyKeyReceivedKey = key
        return dependencyKeyReturnValue
    }

    var setDependencyCallsCount = 0
    var setDependencyReceivedArgs: (dependency: Any, key: String)?
    func set(dependency: Any, for key: String) {
        setDependencyCallsCount += 1
        setDependencyReceivedArgs = (dependency: dependency, key: key)
    }
}

class DependencyContainerTests: XCTestCase {
    private var subject: DependencyContainerImpl!
    private var storage: DependencyStorageMock!

    override func setUp() {
        storage = DependencyStorageMock()
        subject = DependencyContainerImpl(storage: storage)
    }

    func testRegister() throws {
        // given
        let dependency = UUID().uuidString
        let key = String(describing: String.self)
        // when
        subject.register(String.self) { _ in
            dependency
        }
        // then
        XCTAssertEqual(storage.setDependencyCallsCount, 1, "Container should use storage to register dependency")
        XCTAssertEqual(storage.setDependencyReceivedArgs?.dependency as? String, dependency, "Container should register valid dependency")
        XCTAssertEqual(storage.setDependencyReceivedArgs?.key, key, "Container should register dependency using it's type as a key")
    }

    func testRegisterWithName() throws {
        // given
        let dependency = UUID().uuidString
        let name = UUID().uuidString
        let key = String(describing: String.self) + "_" + name
        // when
        subject.register(String.self, name: name) { _ in
            dependency
        }
        // then
        XCTAssertEqual(storage.setDependencyCallsCount, 1, "Container should use storage to register dependency")
        XCTAssertEqual(storage.setDependencyReceivedArgs?.dependency as? String, dependency, "Container should register valid dependency")
        XCTAssertEqual(storage.setDependencyReceivedArgs?.key, key, "Container should register dependency using it's type and name (if name is provided) as a key")
    }

    func testResolve() throws {
        // given
        let expectedDependency = UUID().uuidString
        let key = String(describing: String.self)
        storage.dependencyKeyReturnValue = expectedDependency
        // when
        let receivedDependency = subject.resolve(String.self)
        // then
        XCTAssertEqual(storage.dependencyKeyCallsCount, 1, "Container should use storage to resolve dependency")
        XCTAssertEqual(storage.dependencyKeyReceivedKey, key, "Container should resolve dependency using it's type as a key")
        XCTAssertEqual(receivedDependency, expectedDependency, "Conainer should resolve valid dependency")
    }

    func testResolveWithName() throws {
        // given
        let expectedDependency = UUID().uuidString
        let name = UUID().uuidString
        let key = String(describing: String.self) + "_" + name
        storage.dependencyKeyReturnValue = expectedDependency
        // when
        let receivedDependency = subject.resolve(String.self, name: name)
        // then
        XCTAssertEqual(storage.dependencyKeyCallsCount, 1, "Container should use storage to resolve dependency")
        XCTAssertEqual(storage.dependencyKeyReceivedKey, key, "Container should resolve dependency using it's type as a key")
        XCTAssertEqual(receivedDependency, expectedDependency, "Conainer should resolve valid dependency")
    }
}
