//
//  CountryListServiceManager.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

class CountryListServiceManager: CountryListService {
    private let baseURL = "https://d494e.wiremockapi.cloud/v1.0/"
    private let countryListPath = "all"

    func fetchCountryList() async throws -> Countries {
        guard let url = URL(string: baseURL + countryListPath) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }

        do {
            AppLog.trace("WEB GET \(url.absoluteString)")
            let (data, response) = try await URLSession.shared.data(from: url)
            if let http = response as? HTTPURLResponse {
                AppLog.trace("WEB GET status=\(http.statusCode) bytes=\(data.count)")
            } else {
                AppLog.trace("WEB GET response no-HTTP bytes=\(data.count)")
            }

            let countries = try JSONDecoder().decode(Countries.self, from: data)
            return countries
        } catch let decodingError as DecodingError {
            switch decodingError {
            case .dataCorrupted(let context):
                print("Error de datos corruptos: \(context.debugDescription)")
            case .keyNotFound(let key, let context):
                print("Clave no encontrada: \(key), contexto: \(context.debugDescription)")
            case .typeMismatch(let type, let context):
                print("Error de tipo: \(type), contexto: \(context.debugDescription)")
            case .valueNotFound(let value, let context):
                print("Valor no encontrado: \(value), contexto: \(context.debugDescription)")
            @unknown default:
                print("Error desconocido: \(decodingError.localizedDescription)")
            }
            throw decodingError
        } catch {
            AppLog.trace("WEB GET error: \(error.localizedDescription)")
            throw error
        }
    }
}
