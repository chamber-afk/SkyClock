import Foundation

enum AppError: LocalizedError, Equatable {
    case emptyQuery
    case cityNotFound
    case missingAPIKey
    case invalidAPIKey
    case noInternet
    case serverError
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .emptyQuery:
            return "Type a city name to search."
        case .cityNotFound:
            return "We couldn't find that city. Check the spelling and try again."
        case .missingAPIKey:
            return "Add your OpenWeatherMap API key in Config.swift."
        case .invalidAPIKey:
            return "OpenWeatherMap rejected the API key. Check Config.swift. A new key may need some time to activate."
        case .noInternet:
            return "You appear to be offline. Check your connection and try again."
        case .serverError:
            return "Something went wrong on the server. Please try again."
        case .decodingFailed:
            return "We received an unexpected response. Please try again."
        }
    }
}
