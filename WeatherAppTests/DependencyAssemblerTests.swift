//
//  DependencyAssemblerTests.swift
//  WeatherAppTests
//
//  Created by sahey on 13.02.2021.
//

@testable import WeatherApp
import XCTest

final class DependencyContainerMock<TestableDependency>: DependencyContainer, Equatable {
    static func == (lhs: DependencyContainerMock<TestableDependency>, rhs: DependencyContainerMock<TestableDependency>) -> Bool {
        lhs.identifier == rhs.identifier
    }

    let identifier = UUID()

    var registerDependencyNameCallsCount = 0
    var registerDependencyNameType: TestableDependency?
    var registerDependencyNameName: String?
    var registerDependencyNameFactory: DependencyFactory<TestableDependency>?

    func register<Dependency>(_ type: Dependency.Type, name: String, factory: @escaping DependencyFactory<Dependency>) {
        registerDependencyNameCallsCount += 1
        registerDependencyNameType = type as? TestableDependency
        registerDependencyNameName = name
        registerDependencyNameFactory = factory as? DependencyFactory<TestableDependency>
    }

    var registerDependencyCallsCount = 0
    var registerDependencyType: TestableDependency?
    var registerDependencyFactory: DependencyFactory<TestableDependency>?

    func register<Dependency>(_ type: Dependency.Type, factory: @escaping DependencyFactory<Dependency>) {
        registerDependencyCallsCount += 1
        registerDependencyType = type as? TestableDependency
        registerDependencyFactory = factory as? DependencyFactory<TestableDependency>
    }

    var resolveDependencyNameCallsCount = 0
    var resolveDependencyNameType: TestableDependency?
    var resolveDependencyNameName: String?
    var resolveDependencyNameReturnValue: TestableDependency?

    func resolve<Dependency>(_ type: Dependency.Type, name: String) -> Dependency? {
        resolveDependencyNameCallsCount += 1
        resolveDependencyNameType = type as? TestableDependency
        resolveDependencyNameName = name
        return resolveDependencyNameReturnValue as? Dependency
    }

    var resolveDependencyCallsCount = 0
    var resolveDependencyType: TestableDependency?
    var resolveDependencyReturnValue: TestableDependency?

    func resolve<Dependency>(_ type: Dependency.Type) -> Dependency? {
        resolveDependencyCallsCount += 1
        resolveDependencyType = type as? TestableDependency
        return resolveDependencyReturnValue as? Dependency
    }
}

final class DependencyAssemblyMock<Dependency>: DependencyAssembly {
    var assembleContainerCallsCount = 0
    var assembleContainerContainer: DependencyContainerMock<Dependency>?
    func assemble(container: DependencyContainer) {
        assembleContainerCallsCount += 1
        assembleContainerContainer = container as? DependencyContainerMock<Dependency>
    }
}

class DependencyAssemblerTests: XCTestCase {
    private var subject: DependencyAssemblerImpl!
    private var container: DependencyContainerMock<String>!
    private var assemblies: [DependencyAssemblyMock<String>]!

    override func setUp() {
        super.setUp()
        container = DependencyContainerMock()
        assemblies = [DependencyAssemblyMock()]
        subject = DependencyAssemblerImpl(container: container, assemblies: assemblies)
    }

    func testAssemble() throws {
        // given
        // when
        subject.assemble()
        // then
        assemblies.forEach { assembly in
            XCTAssertEqual(assembly.assembleContainerCallsCount, 1, "Assemble shoud be called for assembly")
            XCTAssertEqual(assembly.assembleContainerContainer, container, "Assembly should be assembled using valid container")
        }
    }
}
