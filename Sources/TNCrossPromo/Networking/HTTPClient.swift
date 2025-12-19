import Foundation

/// Protocol for HTTP operations, enabling testability
protocol HTTPClient: Sendable {
    func data(from url: URL) async throws -> (Data, URLResponse)
}

/// Default implementation using URLSession
final class URLSessionHTTPClient: HTTPClient {
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await session.data(from: url)
    }
}
