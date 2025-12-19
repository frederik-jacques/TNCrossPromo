import Foundation
@testable import TNCrossPromo

final class MockCrossPromoFetcher: CrossPromoFetching, @unchecked Sendable {
    let apps: [PromoApp]
    let error: CrossPromoError?
    private(set) var fetchCallCount = 0

    init(apps: [PromoApp] = [], error: CrossPromoError? = nil) {
        self.apps = apps
        self.error = error
    }

    func fetchApps(from url: URL) async throws -> [PromoApp] {
        fetchCallCount += 1

        if let error {
            throw error
        }

        return apps
    }
}
