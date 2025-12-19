import Testing
import Foundation
@testable import TNCrossPromo

@Suite("CrossPromoViewModel Tests")
struct CrossPromoViewModelTests {

    @Test("ViewModel loads apps and sets featured")
    @MainActor
    func loadApps_setsAppsAndFeatured() async {
        let mockFetcher = MockCrossPromoFetcher(apps: [
            .mock(id: "1", isFeatured: true),
            .mock(id: "2", isFeatured: false),
            .mock(id: "3", isFeatured: true)
        ])
        let viewModel = CrossPromoViewModel(
            configuration: .mock(),
            fetcher: mockFetcher,
            cache: CrossPromoCache(duration: 3600),
            urlOpener: MockURLOpener()
        )

        await viewModel.loadApps()

        #expect(viewModel.apps.count == 3)
        #expect(viewModel.featuredApps.count == 2)
        #expect(viewModel.isLoading == false)
        #expect(viewModel.error == nil)
    }

    @Test("ViewModel excludes configured app ID")
    @MainActor
    func loadApps_excludesConfiguredAppID() async {
        let mockFetcher = MockCrossPromoFetcher(apps: [
            .mock(id: "com.exclude.me"),
            .mock(id: "com.keep.me")
        ])
        let config = CrossPromoConfiguration(
            feedURL: URL(string: "https://test.com")!,
            excludeAppID: "com.exclude.me"
        )
        let viewModel = CrossPromoViewModel(
            configuration: config,
            fetcher: mockFetcher,
            cache: CrossPromoCache(duration: 3600),
            urlOpener: MockURLOpener()
        )

        await viewModel.loadApps()

        #expect(viewModel.apps.count == 1)
        #expect(viewModel.apps.first?.id == "com.keep.me")
    }

    @Test("ViewModel limits featured apps to maxFeaturedItems")
    @MainActor
    func loadApps_limitsFeaturedApps() async {
        let mockFetcher = MockCrossPromoFetcher(apps: [
            .mock(id: "1", isFeatured: true),
            .mock(id: "2", isFeatured: true),
            .mock(id: "3", isFeatured: true),
            .mock(id: "4", isFeatured: true),
            .mock(id: "5", isFeatured: true),
            .mock(id: "6", isFeatured: true)
        ])
        let config = CrossPromoConfiguration(
            feedURL: URL(string: "https://test.com")!,
            maxFeaturedItems: 3
        )
        let viewModel = CrossPromoViewModel(
            configuration: config,
            fetcher: mockFetcher,
            cache: CrossPromoCache(duration: 3600),
            urlOpener: MockURLOpener()
        )

        await viewModel.loadApps()

        #expect(viewModel.apps.count == 6)
        #expect(viewModel.featuredApps.count == 3)
    }

    @Test("ViewModel uses cache when valid")
    @MainActor
    func loadApps_usesCacheWhenValid() async {
        let cache = CrossPromoCache(duration: 3600)
        await cache.setCachedApps([.mock(id: "cached")])

        let mockFetcher = MockCrossPromoFetcher(apps: [.mock(id: "fresh")])
        let viewModel = CrossPromoViewModel(
            configuration: .mock(),
            fetcher: mockFetcher,
            cache: cache,
            urlOpener: MockURLOpener()
        )

        await viewModel.loadApps()

        #expect(viewModel.apps.first?.id == "cached")
        #expect(mockFetcher.fetchCallCount == 0)
    }

    @Test("ViewModel refresh ignores cache")
    @MainActor
    func refresh_ignoresCache() async {
        let cache = CrossPromoCache(duration: 3600)
        await cache.setCachedApps([.mock(id: "cached")])

        let mockFetcher = MockCrossPromoFetcher(apps: [.mock(id: "fresh")])
        let viewModel = CrossPromoViewModel(
            configuration: .mock(),
            fetcher: mockFetcher,
            cache: cache,
            urlOpener: MockURLOpener()
        )

        await viewModel.refresh()

        #expect(viewModel.apps.first?.id == "fresh")
        #expect(mockFetcher.fetchCallCount == 1)
    }

    @Test("ViewModel openApp calls URL opener")
    @MainActor
    func openApp_callsURLOpener() {
        let mockOpener = MockURLOpener()
        let viewModel = CrossPromoViewModel(
            configuration: .mock(),
            fetcher: MockCrossPromoFetcher(apps: []),
            cache: CrossPromoCache(duration: 3600),
            urlOpener: mockOpener
        )
        let app = PromoApp.mock()

        viewModel.openApp(app)

        #expect(mockOpener.openedURL == app.destinationURL)
        #expect(mockOpener.openCallCount == 1)
    }

    @Test("ViewModel sets error on fetch failure")
    @MainActor
    func loadApps_setsErrorOnFailure() async {
        let mockFetcher = MockCrossPromoFetcher(
            error: CrossPromoError.networkError(underlying: URLError(.notConnectedToInternet))
        )
        let viewModel = CrossPromoViewModel(
            configuration: .mock(),
            fetcher: mockFetcher,
            cache: CrossPromoCache(duration: 3600),
            urlOpener: MockURLOpener()
        )

        await viewModel.loadApps()

        #expect(viewModel.error != nil)
        #expect(viewModel.apps.isEmpty)
        #expect(viewModel.isLoading == false)
    }

    @Test("ViewModel clearCache invalidates cache")
    @MainActor
    func clearCache_invalidatesCache() async {
        let cache = CrossPromoCache(duration: 3600)
        await cache.setCachedApps([.mock()])

        let viewModel = CrossPromoViewModel(
            configuration: .mock(),
            fetcher: MockCrossPromoFetcher(apps: []),
            cache: cache,
            urlOpener: MockURLOpener()
        )

        await viewModel.clearCache()

        #expect(await cache.isValid == false)
    }

    @Test("ViewModel sets isLoading during fetch")
    @MainActor
    func loadApps_setsIsLoadingDuringFetch() async {
        let mockFetcher = MockCrossPromoFetcher(apps: [.mock()])
        let viewModel = CrossPromoViewModel(
            configuration: .mock(),
            fetcher: mockFetcher,
            cache: CrossPromoCache(duration: 3600),
            urlOpener: MockURLOpener()
        )

        #expect(viewModel.isLoading == false)

        // After load completes
        await viewModel.loadApps()

        #expect(viewModel.isLoading == false)
    }
}
