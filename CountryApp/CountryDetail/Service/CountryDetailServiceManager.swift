//
//  CountryDetailServiceManager.swift
//  CountryApp
//
//  Created by miguel tomairo on 15/01/25.
//

import Foundation

class CountryDetailServiceManager: CountryDetailService {
    private let baseURL = "https://restcountries.com/v3.1"

    func fetchCountryDetail(by name: String) async throws -> CountryDetail {
        guard let url = URL(string: "\(baseURL)/name/\(name)") else {
            throw NSError(domain: "Invalid URL", code: 0, userInfo: nil)
        }

        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Mostrar el JSON que se recibe del servicio
            if let jsonString = String(data: data, encoding: .utf8) {
                print("JSON recibido: \(jsonString)")
            }
            
            // Intentar decodificar solo los campos necesarios
            let country = try JSONDecoder().decode(CountryDetail.self, from: data)
            
            // Retornar el primer país de la lista
            return country
        } catch let decodingError as DecodingError {
            // Manejo de errores de decodificación
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
            throw decodingError // Lanzar el error de decodificación
        } catch {
            print("Error en la solicitud: \(error.localizedDescription)")
            throw error // Lanzar otros errores
        }
    }

}

