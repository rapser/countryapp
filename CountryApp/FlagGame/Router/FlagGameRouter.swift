//
//  FlagGameRouter.swift
//  CountryApp
//

import OSLog
import SwiftData
import UIKit

final class FlagGameRouter: FlagGameRouterProtocol {
    private static let log = Logger(subsystem: "CountryApp", category: "FlagGameRouter")
    private(set) var interactor: FlagGameInteractor
    /// Nav stack used for instrucciones → quiz → resumen. Se fija al crear el módulo desde Home y al entrar al quiz por si `navigationController` del VC activo viene nil.
    private weak var hostingNavigationController: UINavigationController?

    /// Último resorte cuando `navigationController` del VC activo viene nil (p. ej. transición / jerarquía rara).
    private static func navigationControllerFromKeyWindow() -> UINavigationController? {
        let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
        for scene in scenes {
            for window in scene.windows where window.isKeyWindow {
                guard let root = window.rootViewController else { continue }
                if let nav = root as? UINavigationController { return nav }
                if let nav = root.navigationController { return nav }
            }
        }
        for scene in scenes {
            for window in scene.windows {
                guard let root = window.rootViewController else { continue }
                if let nav = root as? UINavigationController { return nav }
                if let nav = root.navigationController { return nav }
            }
        }
        return nil
    }

    init(interactor: FlagGameInteractor, hostingNavigationController: UINavigationController? = nil) {
        self.interactor = interactor
        self.hostingNavigationController = hostingNavigationController
    }

    static func createModule(modelContext: ModelContext, hostingNavigationController: UINavigationController? = nil) -> UIViewController {
        let persistence = SwiftDataCountryPersistence(modelContext: modelContext)
        let interactor = FlagGameInteractor(persistence: persistence)
        let router = FlagGameRouter(interactor: interactor, hostingNavigationController: hostingNavigationController)
        AppLog.trace("FlagGameRouter createModule hostingNav=\(hostingNavigationController != nil)")
        let presenter = FlagGameInstructionsPresenter(interactor: interactor, router: router)
        let vc = FlagGameInstructionsViewController(presenter: presenter)
        presenter.view = vc
        presenter.router = router
        return vc
    }

    func pushQuiz(from viewController: UIViewController) {
        guard let nav = viewController.navigationController else {
            AppLog.trace("FlagGameRouter pushQuiz ERROR navigationController nil vc=\(String(describing: type(of: viewController)))")
            Self.log.error("pushQuiz: navigationController is nil for \(String(describing: type(of: viewController)))")
            return
        }
        hostingNavigationController = nav
        AppLog.trace("FlagGameRouter pushQuiz OK stack=\(nav.viewControllers.count)")
        Self.log.info("pushQuiz: pushing quiz")
        let presenter = FlagGameQuizPresenter(interactor: interactor, router: self)
        let vc = FlagGameQuizViewController(presenter: presenter, gameRouter: self)
        presenter.view = vc
        presenter.router = self
        nav.pushViewController(vc, animated: true)
    }

    func pushSummary(from viewController: UIViewController) {
        let summary = interactor.buildSummary()
        AppLog.trace("FlagGameRouter pushSummary score=\(summary.score) ok=\(summary.correctCount) bad=\(summary.wrongCount) skip=\(summary.skippedCount)")
        Self.log.info("pushSummary entrada score=\(summary.score)")

        let presenter = FlagGameSummaryPresenter(router: self)
        let vc = FlagGameSummaryViewController(presenter: presenter, summary: summary)
        presenter.router = self

        let fromNav = viewController.navigationController
        let hosting = hostingNavigationController
        let keyNav = Self.navigationControllerFromKeyWindow()
        let nav = fromNav ?? hosting ?? keyNav
        AppLog.trace("FlagGameRouter pushSummary navVC=\(fromNav != nil) hosting=\(hosting != nil) keyWin=\(keyNav != nil) final=\(nav != nil)")
        guard let nav else {
            AppLog.trace("FlagGameRouter pushSummary MODAL (sin nav)")
            Self.log.error("pushSummary: no UINavigationController; modal fallback")
            let wrap = UINavigationController(rootViewController: vc)
            wrap.modalPresentationStyle = .fullScreen
            viewController.present(wrap, animated: true)
            return
        }
        let push = {
            AppLog.trace("FlagGameRouter pushSummary push antes=\(nav.viewControllers.count)")
            nav.pushViewController(vc, animated: true)
            AppLog.trace("FlagGameRouter pushSummary push después=\(nav.viewControllers.count)")
        }
        if Thread.isMainThread {
            push()
        } else {
            DispatchQueue.main.async(execute: push)
        }
    }

    func exitToHome(from viewController: UIViewController) {
        if let presentedNav = viewController.navigationController,
           presentedNav.presentingViewController != nil {
            AppLog.trace("FlagGameRouter exitToHome dismiss modal")
            let host = hostingNavigationController ?? Self.navigationControllerFromKeyWindow()
            presentedNav.dismiss(animated: true) {
                host?.popToRootViewController(animated: true)
            }
            return
        }
        let nav = viewController.navigationController ?? hostingNavigationController ?? Self.navigationControllerFromKeyWindow()
        AppLog.trace("FlagGameRouter exitToHome popToRoot nav=\(nav != nil)")
        nav?.popToRootViewController(animated: true)
    }
}
