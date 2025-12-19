import Foundation

/// Protocol for fetching promo apps, enabling testability
public protocol CrossPromoFetching: Sendable {
    func fetchApps(from url: URL) async throws -> [PromoApp]
}

/// Default implementation for fetching promo apps from a remote JSON endpoint
final class CrossPromoFetcher: CrossPromoFetching {
    private let httpClient: HTTPClient
    private let decoder: JSONDecoder

    init(httpClient: HTTPClient = URLSessionHTTPClient()) {
        self.httpClient = httpClient
        self.decoder = JSONDecoder()
    }

    func fetchApps(from url: URL) async throws -> [PromoApp] {
        let data: Data
        let response: URLResponse

        do {
            (data, response) = try await httpClient.data(from: url)
        } catch {
            throw CrossPromoError.networkError(underlying: error)
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw CrossPromoError.invalidResponse(statusCode: -1)
        }

        guard (200...299).contains(httpResponse.statusCode) else {
            throw CrossPromoError.invalidResponse(statusCode: httpResponse.statusCode)
        }

        guard !data.isEmpty else {
            throw CrossPromoError.noData
        }

        let listDTO: PromoAppListDTO
        do {
            listDTO = try decoder.decode(PromoAppListDTO.self, from: data)
        } catch {
            throw CrossPromoError.decodingError(underlying: error)
        }

        // Convert DTOs to domain models, filtering out any with invalid URLs
        var apps: [PromoApp] = []
        for dto in listDTO.apps {
            if let app = PromoApp(dto: dto) {
                apps.append(app)
            } else {
                #if DEBUG
                print("[TNCrossPromo] Dropped invalid app '\(dto.id)': invalid or disallowed URL scheme (imageURL: \(dto.imageURL), destinationURL: \(dto.destinationURL))")
                #endif
            }
        }

        apps.sort { lhs, rhs in
            if lhs.sortOrder != rhs.sortOrder {
                return lhs.sortOrder < rhs.sortOrder
            }
            return lhs.title.localizedCaseInsensitiveCompare(rhs.title) == .orderedAscending
        }

        return apps
    }
}
