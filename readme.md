# WeatherApp

![](Weather.png)

Hello there! WeatherApp is a simple app that fetches and displays the weather for your current location. If you don't want to share your location, it uses [Yakutsk](https://www.nationalgeographic.com/magazine/2018/02/explore-yakutsk-russia-coldest-city/) as the default location.

# Architecture

## Screen aka Module

The app contains one module, the module is UIViewController decomposed into small components. Each module contains:
- **DisplayLogic** displays data
- **Interactor** performs business logic
- **Repository** provides data to business logic. Uses Combine to orchestrate with the service layer
- **Presenter** maps data to a human-readable format
- **Router** routes to other modules or open some links

There is a service layer below the repository component
- **WeatherApi** provides data according to contract
- **LocationProvider** provides current device location

## Dependency Container

Dependency Container handles the dependencies of an app. Each module or service should provide an `Assembly` by implementing a `DependencyAssembly` protocol. Each layer of an app should provide a declaration of the `ComponentAssembly` class. The declaration of the `ComponentAssembly` should contain the dependencies (implemented `DependencyAssembly` list) of its layer. Inspired by [Swinject ❤️](https://github.com/Swinject/Swinject)

### Usage:
``` Swift
//////////////// Services layer
// Assembly of a concrete service
final class WeatherApiServiceAssembly: DependencyAssembly {
    func assemble(container: DependencyContainer) {
        container.register(WeatherApiService.self) { _ in
            WeatherApiServiceImpl()
        }
    }
}
extension ComponentAssembly {
    // All assemblies of this layer
    static var services: DependencyAssembly {
        ComponentAssembly(
            WeatherApiServiceAssembly(),
            /*
                Many other service assemblies
            */
        )
    }
}
//////////////// Screens layer
// Assembly of a concrete screen/module
final class WeatherAssembly: DependencyAssembly {
    func assemble(container: DependencyContainer) {
        container.register(WeatherBuilder.self) { container in
            let builder = WeatherBuilderImpl(
                // Resolving previosly registered service WeatherApiService
                apiService: container.resolve(WeatherApiService.self)!,
            )
            return builder
        }
    }
}
extension ComponentAssembly {
    // All assemblies of this layer
    static var screens: DependencyAssembly {
        ComponentAssembly(
            WeatherAssembly(),
            /*
                Many other cool screens
            */
        )
    }
}

class AppDelegate {
    private let container = DependencyContainerImpl()
    private lazy var assembler: DependencyAssembler = {
        DependencyAssemblerImpl(
            container: container,
            assemblies: [
                ComponentAssembly.services,
                ComponentAssembly.screens
            ])
    }()
}
```

## Class diagrams:
- [Weather Module](Weather.pdf)
- [Dependency Container](DependencyContainer.pdf)
