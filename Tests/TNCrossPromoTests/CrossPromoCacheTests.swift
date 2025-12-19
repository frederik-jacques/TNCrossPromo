import Testing
import Foundation
@testable import TNCrossPromo

@Suite("CrossPromoCache Tests")
struct CrossPromoCacheTests {

    @Test("Cache stores and retrieves apps")
    func storesAndRetrievesApps() async {
        let cache = CrossPromoCache(duration: 3600)
        let apps = [PromoApp.mock(id: "cached-app")]

        await cache.setCachedApps(apps)
        let retrieved = await cache.getCachedApps()

        #expect(retrieved?.count == 1)
        #expect(retrieved?.first?.id == "cached-app")
    }

    @Test("Cache returns nil when empty")
    func returnsNilWhenEmpty() async {
        let cache = CrossPromoCache(duration: 3600)

        let retrieved = await cache.getCachedApps()

        #expect(retrieved == nil)
    }

    @Test("Cache expires after duration")
    func expiresAfterDuration() async throws {
        let cache = CrossPromoCache(duration: 0.1) // 100ms
        await cache.setCachedApps([PromoApp.mock()])

        // Wait for cache to expire
        try await Task.sleep(for: .milliseconds(150))

        let retrieved = await cache.getCachedApps()

        #expect(retrieved == nil)
    }

    @Test("Cache isValid returns correct state")
    func isValidReturnsCorrectState() async {
        let cache = CrossPromoCache(duration: 3600)

        #expect(await cache.isValid == false)

        await cache.setCachedApps([PromoApp.mock()])

        #expect(await cache.isValid == true)
    }

    @Test("Cache invalidate clears data")
    func invalidateClearsData() async {
        let cache = CrossPromoCache(duration: 3600)
        await cache.setCachedApps([PromoApp.mock()])

        #expect(await cache.getCachedApps() != nil)

        await cache.invalidate()

        #expect(await cache.getCachedApps() == nil)
        #expect(await cache.isValid == false)
    }

    @Test("Cache overwrites previous data")
    func overwritesPreviousData() async {
        let cache = CrossPromoCache(duration: 3600)

        await cache.setCachedApps([PromoApp.mock(id: "first")])
        await cache.setCachedApps([PromoApp.mock(id: "second"), PromoApp.mock(id: "third")])

        let retrieved = await cache.getCachedApps()

        #expect(retrieved?.count == 2)
        #expect(retrieved?.first?.id == "second")
    }
}
