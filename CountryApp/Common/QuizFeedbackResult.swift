//
//  QuizFeedbackResult.swift
//  CountryApp
//
//  Datos que alimentan la pantalla de feedback a pantalla completa tras cada pregunta.
//  Compartido por FlagGame y CapitalGame.
//

import Foundation

struct QuizFeedbackResult {
    let isCorrect: Bool
    /// Puntos otorgados por esta pregunta (base + bonus por rapidez). 0 si se falló.
    let awardedPoints: Int
    /// Puntos acumulados en la ronda tras esta pregunta.
    let totalPoints: Int
    let flagAssetCode: String
    let questionPrompt: String
    let yourAnswer: String
    let correctAnswer: String
    /// Si es la última pregunta, el botón de continuar lleva al resumen.
    let isLastQuestion: Bool
}
