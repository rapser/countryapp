//
//  HomeInteractor.swift
//  CountryApp
//

import Foundation

final class HomeInteractor: HomeInteractorProtocol {
    private let persistence: CountryPersistenceProtocol
    private let service: CountryListService
    private var didBootstrap = false

    init(persistence: CountryPersistenceProtocol, service: CountryListService) {
        self.persistence = persistence
        self.service = service
    }

    func bootstrapCountriesIfNeeded() async {
        if didBootstrap { return }
        didBootstrap = true

        do {
            let existingCount = try await MainActor.run { try persistence.persistedCount() }
            if existingCount > 0 {
                AppLog.trace("Home bootstrap: ya hay \(existingCount) países guardados, no se llama a la red")
                return
            }
        } catch {
            // Si falla el conteo, intentamos bootstrap igualmente.
            AppLog.trace("Home bootstrap: error leyendo SwiftData count: \(error.localizedDescription)")
        }

        do {
            AppLog.trace("Home bootstrap: descargando países desde API (SwiftData vacío)")
            let countries = try await service.fetchCountryList()
            try await MainActor.run { try persistence.replaceAll(from: countries) }
            let newCount = (try? await MainActor.run { try persistence.persistedCount() }) ?? -1
            AppLog.trace("Home bootstrap: guardado completo, count=\(newCount)")
        } catch {
            AppLog.trace("Home bootstrap: falló descarga/guardado: \(error.localizedDescription)")
        }
    }
}
