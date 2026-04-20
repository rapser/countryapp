//
//  CountryDetailServiceManager.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

class CountryDetailServiceManager: CountryDetailService {
    private let baseURL = "https://d494e.wiremockapi.cloud/v1.0/"
    private let countryDetailPath = "name/all"

    func fetchCountryDetail(by name: String) async throws -> CountryDetail {
        guard let url = URL(string: baseURL + countryDetailPath) else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON recibido: \(jsonString)")
            }
            
            let allDetails = try JSONDecoder().decode(CountryDetail.self, from: data)
            let normalizedQuery = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            let match = allDetails.first { $0.name.common.lowercased() == normalizedQuery }
            return match.map { [$0] } ?? []
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
            print("Error en la solicitud: \(error.localizedDescription)")
            throw error
        }
    }

}

