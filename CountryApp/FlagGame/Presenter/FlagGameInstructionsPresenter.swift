//
//  FlagGameInstructionsPresenter.swift
//  CountryApp
//

import OSLog
import UIKit

protocol FlagGameInstructionsPresenterProtocol: AnyObject {
    func didTapPlay(from viewController: UIViewController)
}

final class FlagGameInstructionsPresenter: FlagGameInstructionsPresenterProtocol {
    private static let log = Logger(subsystem: "CountryApp", category: "FlagGameInstructions")

    weak var view: FlagGameInstructionsViewProtocol?
    /// Must be strong: `FlagGameRouter` is not owned by the navigation stack; a weak ref would deallocate it right after `createModule` returns.
    var router: FlagGameRouterProtocol?
    private let interactor: FlagGameInteractorProtocol

    init(interactor: FlagGameInteractorProtocol, router: FlagGameRouterProtocol?) {
        self.interactor = interactor
        self.router = router
    }

    func didTapPlay(from viewController: UIViewController) {
        Self.log.debug("Jugar tapped")
        Task { @MainActor in
            // Solo datos locales (SwiftData): no hace falta spinner; evitamos doble tap.
            view?.setPrepareInProgress(true)
            defer { view?.setPrepareInProgress(false) }
            do {
                try await interactor.ensureCountriesLoaded()
                try await interactor.startNewRound()
                guard let router else {
                    Self.log.error("router is nil after prepare; cannot push quiz")
                    view?.showError(message: "Error interno: no hay router de navegación.")
                    return
                }
                Self.log.debug("Pushing quiz screen")
                router.pushQuiz(from: viewController)
            } catch {
                Self.log.error("Prepare game failed: \(String(describing: error))")
                let message: String
                if let fe = error as? FlagGameError, fe == .notEnoughCountries {
                    message = "No hay suficientes países con bandera guardada. Abre primero el listado para sincronizar datos."
                } else {
                    message = error.localizedDescription
                }
                view?.showError(message: message)
            }
        }
    }
}
