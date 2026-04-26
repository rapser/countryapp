//
//  CapitalGameInstructionsPresenter.swift
//  CountryApp
//

import OSLog
import UIKit

protocol CapitalGameInstructionsPresenterProtocol: AnyObject {
    func didTapPlay(from viewController: UIViewController)
}

final class CapitalGameInstructionsPresenter: CapitalGameInstructionsPresenterProtocol {
    private static let log = Logger(subsystem: "CountryApp", category: "CapitalGameInstructions")

    weak var view: CapitalGameInstructionsViewProtocol?
    var router: CapitalGameRouterProtocol?
    private let interactor: CapitalGameInteractorProtocol

    init(interactor: CapitalGameInteractorProtocol, router: CapitalGameRouterProtocol?) {
        self.interactor = interactor
        self.router = router
    }

    func didTapPlay(from viewController: UIViewController) {
        let interactor = interactor
        let router = router
        Task {
            do {
                try await interactor.ensureCountriesLoaded()
                try await interactor.startNewRound()
                await MainActor.run {
                    router?.pushQuiz(from: viewController)
                }
            } catch {
                await MainActor.run {
                    let msg = "No hay suficientes países con capital para jugar. Asegúrate de haber sincronizado el listado."
                    let alert = UIAlertController(title: "No se pudo preparar el juego", message: msg, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default))
                    viewController.present(alert, animated: true)
                }
                Self.log.error("didTapPlay error: \(error.localizedDescription, privacy: .public)")
            }
        }
    }
}

