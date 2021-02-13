//
//  DependencyAssembler.swift
//  WeatherApp
//
//  Created by sahey on 13.02.2021.
//

import Foundation

protocol DependencyAssembly {
    func assemble(container: DependencyContainer)
}

protocol DependencyAssembler {
    func assemble()
}

// MARK: - Assembler

final class DependencyAssemblerImpl {
    private let container: DependencyContainer
    private let assemblies: [DependencyAssembly]

    init(container: DependencyContainer, assemblies: [DependencyAssembly]) {
        self.container = container
        self.assemblies = assemblies
    }
}

extension DependencyAssemblerImpl: DependencyAssembler {
    func assemble() {
        assemblies.forEach { $0.assemble(container: container) }
    }
}

// MARK: - Assembly

final class ComponentAssembly: DependencyAssembly {
    private let assemblies: [DependencyAssembly]

    init(_ assemblies: DependencyAssembly...) {
        self.assemblies = assemblies
    }

    func assemble(container: DependencyContainer) {
        assemblies.forEach { $0.assemble(container: container) }
    }
}
