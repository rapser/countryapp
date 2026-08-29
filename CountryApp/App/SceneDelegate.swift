//
//  SceneDelegate.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import SwiftData
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var modelContainer: ModelContainer?
    private var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        do {
            modelContainer = try ModelContainer(for: Schema([PersistedCountry.self]))
        } catch {
            fatalError("Could not open SwiftData store: \(error)")
        }

        guard let modelContainer else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let modelContext = ModelContext(modelContainer)
        let navigationController = UINavigationController()
        let coordinator = AppCoordinator(navigationController: navigationController, modelContext: modelContext)
        appCoordinator = coordinator
        coordinator.start()

        window.rootViewController = navigationController
        window.makeKeyAndVisible()
        AppLog.trace("SceneDelegate: ventana activa, AppCoordinator iniciado")
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
    }
}
