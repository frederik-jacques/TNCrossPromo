import Foundation
@testable import TNCrossPromo

final class MockURLOpener: URLOpening, @unchecked Sendable {
    private(set) var openedURL: URL?
    private(set) var openCallCount = 0

    @MainActor
    func open(_ url: URL) {
        openedURL = url
        openCallCount += 1
    }
}
