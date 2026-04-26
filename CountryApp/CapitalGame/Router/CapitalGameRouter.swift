//
//  CapitalGameRouter.swift
//  CountryApp
//

import OSLog
import SwiftData
import UIKit

final class CapitalGameRouter: CapitalGameRouterProtocol {
    private static let log = Logger(subsystem: "CountryApp", category: "CapitalGameRouter")
    private(set) var interactor: CapitalGameInteractor
    private weak var hostingNavigationController: UINavigationController?

    init(interactor: CapitalGameInteractor, hostingNavigationController: UINavigationController? = nil) {
        self.interactor = interactor
        self.hostingNavigationController = hostingNavigationController
    }

    static func createModule(modelContext: ModelContext, hostingNavigationController: UINavigationController? = nil) -> UIViewController {
        let persistence = SwiftDataCountryPersistence(modelContext: modelContext)
        let interactor = CapitalGameInteractor(persistence: persistence)
        let router = CapitalGameRouter(interactor: interactor, hostingNavigationController: hostingNavigationController)
        let presenter = CapitalGameInstructionsPresenter(interactor: interactor, router: router)
        let vc = CapitalGameInstructionsViewController(presenter: presenter)
        presenter.view = vc
        presenter.router = router
        return vc
    }

    func pushQuiz(from viewController: UIViewController) {
        guard let nav = viewController.navigationController else {
            Self.log.error("pushQuiz: navigationController is nil")
            return
        }
        hostingNavigationController = nav
        let presenter = CapitalGameQuizPresenter(interactor: interactor, router: self)
        let vc = CapitalGameQuizViewController(presenter: presenter, gameRouter: self)
        presenter.view = vc
        presenter.router = self
        nav.pushViewController(vc, animated: true)
    }

    func pushSummary(from viewController: UIViewController) {
        let summary = interactor.buildSummary()
        let presenter = CapitalGameSummaryPresenter(router: self)
        let vc = CapitalGameSummaryViewController(presenter: presenter, summary: summary)
        presenter.router = self

        let nav = viewController.navigationController ?? hostingNavigationController
        guard let nav else {
            let wrap = UINavigationController(rootViewController: vc)
            wrap.modalPresentationStyle = .fullScreen
            viewController.present(wrap, animated: true)
            return
        }
        nav.pushViewController(vc, animated: true)
    }

    func exitToHome(from viewController: UIViewController) {
        let nav = viewController.navigationController ?? hostingNavigationController
        nav?.popToRootViewController(animated: true)
    }
}

