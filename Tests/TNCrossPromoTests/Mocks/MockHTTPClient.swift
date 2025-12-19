import Foundation
@testable import TNCrossPromo

final class MockHTTPClient: HTTPClient, @unchecked Sendable {
    let responseData: Data?
    let statusCode: Int
    let error: Error?
    private(set) var requestedURL: URL?

    init(responseData: Data? = nil, statusCode: Int = 200, error: Error? = nil) {
        self.responseData = responseData
        self.statusCode = statusCode
        self.error = error
    }

    func data(from url: URL) async throws -> (Data, URLResponse) {
        requestedURL = url

        if let error {
            throw error
        }

        let response = HTTPURLResponse(
            url: url,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: nil
        )!

        return (responseData ?? Data(), response)
    }
}
