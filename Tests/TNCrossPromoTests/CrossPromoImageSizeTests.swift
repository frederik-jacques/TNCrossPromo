import Testing
@testable import TNCrossPromo

@Suite("CrossPromoImageSize Tests")
struct CrossPromoImageSizeTests {
    @Test("ImageSize returns correct cardWidth")
    func imageSizeCardWidth() {
        #expect(CrossPromoImageSize.auto(maxWidth: 300).cardWidth == 300)
        #expect(CrossPromoImageSize.square(150).cardWidth == 150)
        #expect(CrossPromoImageSize.fixed(width: 200, height: 100).cardWidth == 200)
    }

    @Test("ImageSize returns correct imageHeight")
    func imageSizeImageHeight() {
        #expect(CrossPromoImageSize.auto(maxWidth: 300).imageHeight == 240)
        #expect(CrossPromoImageSize.square(150).imageHeight == 150)
        #expect(CrossPromoImageSize.fixed(width: 200, height: 100).imageHeight == 100)
    }
}
