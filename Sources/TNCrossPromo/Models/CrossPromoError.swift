import Foundation

/// Errors that can occur during cross-promotion operations
public enum CrossPromoError: Error, Sendable {
    case invalidURL
    case networkError(underlying: Error)
    case decodingError(underlying: Error)
    case invalidResponse(statusCode: Int)
    case noData
}

extension CrossPromoError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The feed URL is invalid."
        case .networkError(let underlying):
            return "Network error: \(underlying.localizedDescription)"
        case .decodingError(let underlying):
            return "Failed to decode response: \(underlying.localizedDescription)"
        case .invalidResponse(let statusCode):
            return "Invalid server response (status code: \(statusCode))."
        case .noData:
            return "No data received from server."
        }
    }
}
