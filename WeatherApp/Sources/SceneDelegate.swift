//
//  SceneDelegate.swift
//  WeatherApp
//
//  Created by sahey on 11.02.2021.
//

import UIKit

protocol AppAssembler {
    var container: DependencyContainer { get }

    func assemble()
}

final class AppAssemblerImpl: AppAssembler {
    var container: DependencyContainer = DependencyContainerImpl()
    private lazy var assembler: DependencyAssembler = {
        DependencyAssemblerImpl(
            container: container,
            assemblies: [
                ComponentAssembly.services,
                ComponentAssembly.screens
            ])
    }()

    func assemble() {
        assembler.assemble()
    }
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private let appAssembler: AppAssembler = {
        let appAssembler = AppAssemblerImpl()
        appAssembler.assemble()
        return appAssembler
    }()

    private lazy var root: (RootInteractor & RootDeeplinkable) = {
        let appBuilder = appAssembler.container.resolve(RootBuilder.self)!
        return appBuilder.build(input: RootBuilderInput(window: window!))
    }()

    private lazy var deeplinkRouter: DeeplinkRouter = {
        DeeplinkRouterImpl(root: root)
    }()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            self.window = window
            root.startApp()
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        deeplinkRouter.route(url: url)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
}
