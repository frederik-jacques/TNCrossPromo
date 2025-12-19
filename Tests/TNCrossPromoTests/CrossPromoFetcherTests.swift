import Testing
import Foundation
@testable import TNCrossPromo

@Suite("CrossPromoFetcher Tests")
struct CrossPromoFetcherTests {

    @Test("Fetcher returns apps for valid response")
    func withValidResponse_returnsApps() async throws {
        let mockClient = MockHTTPClient(
            responseData: TestData.validJSON,
            statusCode: 200
        )
        let fetcher = CrossPromoFetcher(httpClient: mockClient)

        let apps = try await fetcher.fetchApps(from: URL(string: "https://test.com")!)

        #expect(apps.count == 2)
        #expect(apps[0].id == "com.example.app1")
        #expect(apps[0].isFeatured == true)
        #expect(apps[1].id == "com.example.app2")
    }

    @Test("Fetcher throws network error")
    func withNetworkError_throwsNetworkError() async {
        let mockClient = MockHTTPClient(error: URLError(.notConnectedToInternet))
        let fetcher = CrossPromoFetcher(httpClient: mockClient)

        await #expect(throws: CrossPromoError.self) {
            try await fetcher.fetchApps(from: URL(string: "https://test.com")!)
        }
    }

    @Test("Fetcher throws for non-2xx status code")
    func withErrorStatusCode_throwsInvalidResponse() async {
        let mockClient = MockHTTPClient(
            responseData: Data(),
            statusCode: 404
        )
        let fetcher = CrossPromoFetcher(httpClient: mockClient)

        do {
            _ = try await fetcher.fetchApps(from: URL(string: "https://test.com")!)
            Issue.record("Expected error to be thrown")
        } catch let error as CrossPromoError {
            if case .invalidResponse(let statusCode) = error {
                #expect(statusCode == 404)
            } else {
                Issue.record("Expected invalidResponse error")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("Fetcher throws for invalid JSON")
    func withInvalidJSON_throwsDecodingError() async {
        let mockClient = MockHTTPClient(
            responseData: "not valid json".data(using: .utf8)!,
            statusCode: 200
        )
        let fetcher = CrossPromoFetcher(httpClient: mockClient)

        await #expect(throws: CrossPromoError.self) {
            try await fetcher.fetchApps(from: URL(string: "https://test.com")!)
        }
    }

    @Test("Fetcher throws for empty data")
    func withEmptyData_throwsNoData() async {
        let mockClient = MockHTTPClient(
            responseData: Data(),
            statusCode: 200
        )
        let fetcher = CrossPromoFetcher(httpClient: mockClient)

        do {
            _ = try await fetcher.fetchApps(from: URL(string: "https://test.com")!)
            Issue.record("Expected error to be thrown")
        } catch let error as CrossPromoError {
            if case .noData = error {
                // Expected
            } else {
                Issue.record("Expected noData error, got \(error)")
            }
        } catch {
            Issue.record("Unexpected error type: \(error)")
        }
    }

    @Test("Fetcher filters out invalid URLs")
    func filtersInvalidURLs() async throws {
        let mockClient = MockHTTPClient(
            responseData: TestData.jsonWithInvalidURL,
            statusCode: 200
        )
        let fetcher = CrossPromoFetcher(httpClient: mockClient)

        let apps = try await fetcher.fetchApps(from: URL(string: "https://test.com")!)

        #expect(apps.count == 1)
        #expect(apps.first?.id == "valid")
    }

    @Test("Fetcher sorts apps by sortOrder then title")
    func sortsAppsCorrectly() async throws {
        let json = """
        {
            "apps": [
                {"id": "c", "title": "Zebra", "short_description": "d", "image_url": "https://e.com/i.png", "destination_url": "https://a.com/1", "sort_order": 1},
                {"id": "a", "title": "Apple", "short_description": "d", "image_url": "https://e.com/i.png", "destination_url": "https://a.com/2", "sort_order": 1},
                {"id": "b", "title": "Banana", "short_description": "d", "image_url": "https://e.com/i.png", "destination_url": "https://a.com/3", "sort_order": 0}
            ]
        }
        """.data(using: .utf8)!

        let mockClient = MockHTTPClient(responseData: json, statusCode: 200)
        let fetcher = CrossPromoFetcher(httpClient: mockClient)

        let apps = try await fetcher.fetchApps(from: URL(string: "https://test.com")!)

        #expect(apps[0].id == "b") // sortOrder 0
        #expect(apps[1].id == "a") // sortOrder 1, "Apple" < "Zebra"
        #expect(apps[2].id == "c") // sortOrder 1, "Zebra"
    }

    @Test("Fetcher handles minimal JSON without version")
    func handlesMinimalJSON() async throws {
        let mockClient = MockHTTPClient(
            responseData: TestData.minimalJSON,
            statusCode: 200
        )
        let fetcher = CrossPromoFetcher(httpClient: mockClient)

        let apps = try await fetcher.fetchApps(from: URL(string: "https://test.com")!)

        #expect(apps.count == 1)
        #expect(apps.first?.id == "minimal")
        #expect(apps.first?.isFeatured == false) // default value
    }
}
