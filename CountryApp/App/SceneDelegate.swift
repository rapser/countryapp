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
        let homeViewController = HomeRouter.createModule(modelContext: modelContext)
        let navigationController = UINavigationController(rootViewController: homeViewController)
        window.rootViewController = navigationController

        window.makeKeyAndVisible()
        AppLog.trace("SceneDelegate: ventana activa, raíz UINavigationController")
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
