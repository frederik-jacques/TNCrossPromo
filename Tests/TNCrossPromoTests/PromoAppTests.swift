import Testing
import Foundation
@testable import TNCrossPromo

@Suite("PromoApp Tests")
struct PromoAppTests {

    @Test("PromoApp initializes with valid DTO")
    func initFromDTO_withValidURLs_succeeds() {
        let dto = PromoAppDTO(
            id: "test",
            title: "Test App",
            shortDescription: "A test description",
            imageURL: "https://example.com/img.png",
            destinationURL: "https://apps.apple.com/app/123",
            isFeatured: true,
            sortOrder: 5
        )

        let app = PromoApp(dto: dto)

        #expect(app != nil)
        #expect(app?.id == "test")
        #expect(app?.title == "Test App")
        #expect(app?.subtitle == "A test description")
        #expect(app?.imageURL.absoluteString == "https://example.com/img.png")
        #expect(app?.destinationURL.absoluteString == "https://apps.apple.com/app/123")
        #expect(app?.isFeatured == true)
        #expect(app?.sortOrder == 5)
    }

    @Test("PromoApp returns nil for invalid image URL")
    func initFromDTO_withInvalidImageURL_returnsNil() {
        let dto = PromoAppDTO(
            id: "test",
            title: "Test",
            shortDescription: "Desc",
            imageURL: "not a valid url",
            destinationURL: "https://valid.com",
            isFeatured: nil,
            sortOrder: nil
        )

        let app = PromoApp(dto: dto)

        #expect(app == nil)
    }

    @Test("PromoApp returns nil for invalid destination URL")
    func initFromDTO_withInvalidDestinationURL_returnsNil() {
        let dto = PromoAppDTO(
            id: "test",
            title: "Test",
            shortDescription: "Desc",
            imageURL: "https://valid.com/image.png",
            destinationURL: "not valid",
            isFeatured: nil,
            sortOrder: nil
        )

        let app = PromoApp(dto: dto)

        #expect(app == nil)
    }

    @Test("PromoApp uses default values for nil optional fields")
    func initFromDTO_withNilOptionals_usesDefaults() {
        let dto = PromoAppDTO(
            id: "test",
            title: "Test",
            shortDescription: "Desc",
            imageURL: "https://example.com/img.png",
            destinationURL: "https://apps.apple.com/app/1",
            isFeatured: nil,
            sortOrder: nil
        )

        let app = PromoApp(dto: dto)

        #expect(app?.isFeatured == false)
        #expect(app?.sortOrder == Int.max)
    }

    @Test("PromoApp public initializer works correctly")
    func publicInit_createsAppCorrectly() {
        let app = PromoApp(
            id: "public-test",
            title: "Public Test",
            subtitle: "Created via public init",
            imageURL: URL(string: "https://example.com/img.png")!,
            destinationURL: URL(string: "https://apps.apple.com/app/1")!,
            isFeatured: true,
            sortOrder: 10
        )

        #expect(app.id == "public-test")
        #expect(app.title == "Public Test")
        #expect(app.subtitle == "Created via public init")
        #expect(app.isFeatured == true)
        #expect(app.sortOrder == 10)
    }

    @Test("PromoApp conforms to Hashable")
    func hashable_conformance() {
        let app1 = PromoApp.mock(id: "app1")
        let app2 = PromoApp.mock(id: "app2")
        let app1Copy = PromoApp.mock(id: "app1")

        var set = Set<PromoApp>()
        set.insert(app1)
        set.insert(app2)
        set.insert(app1Copy)

        #expect(set.count == 2)
    }

    // MARK: - URL Scheme Validation Tests

    @Test("PromoApp rejects http image URL scheme")
    func initFromDTO_withHttpImageURL_returnsNil() {
        let dto = PromoAppDTO(
            id: "test",
            title: "Test",
            shortDescription: "Desc",
            imageURL: "http://example.com/image.png",
            destinationURL: "https://apps.apple.com/app/1",
            isFeatured: nil,
            sortOrder: nil
        )

        #expect(PromoApp(dto: dto) == nil)
    }

    @Test("PromoApp rejects file image URL scheme")
    func initFromDTO_withFileImageURL_returnsNil() {
        let dto = PromoAppDTO(
            id: "test",
            title: "Test",
            shortDescription: "Desc",
            imageURL: "file:///etc/passwd",
            destinationURL: "https://apps.apple.com/app/1",
            isFeatured: nil,
            sortOrder: nil
        )

        #expect(PromoApp(dto: dto) == nil)
    }

    @Test("PromoApp rejects tel destination URL scheme")
    func initFromDTO_withTelDestinationURL_returnsNil() {
        let dto = PromoAppDTO(
            id: "test",
            title: "Test",
            shortDescription: "Desc",
            imageURL: "https://example.com/image.png",
            destinationURL: "tel:+1234567890",
            isFeatured: nil,
            sortOrder: nil
        )

        #expect(PromoApp(dto: dto) == nil)
    }

    @Test("PromoApp rejects sms destination URL scheme")
    func initFromDTO_withSmsDestinationURL_returnsNil() {
        let dto = PromoAppDTO(
            id: "test",
            title: "Test",
            shortDescription: "Desc",
            imageURL: "https://example.com/image.png",
            destinationURL: "sms:+1234567890",
            isFeatured: nil,
            sortOrder: nil
        )

        #expect(PromoApp(dto: dto) == nil)
    }

    @Test("PromoApp accepts itms-apps destination URL scheme")
    func initFromDTO_withItmsAppsDestinationURL_succeeds() {
        let dto = PromoAppDTO(
            id: "test",
            title: "Test",
            shortDescription: "Desc",
            imageURL: "https://example.com/image.png",
            destinationURL: "itms-apps://apps.apple.com/app/id123456789",
            isFeatured: nil,
            sortOrder: nil
        )

        let app = PromoApp(dto: dto)

        #expect(app != nil)
        #expect(app?.destinationURL.scheme == "itms-apps")
    }

    @Test("PromoApp scheme validation is case insensitive")
    func initFromDTO_withUppercaseScheme_succeeds() {
        let dto = PromoAppDTO(
            id: "test",
            title: "Test",
            shortDescription: "Desc",
            imageURL: "HTTPS://example.com/image.png",
            destinationURL: "ITMS-APPS://apps.apple.com/app/id123456789",
            isFeatured: nil,
            sortOrder: nil
        )

        #expect(PromoApp(dto: dto) != nil)
    }
}

@Suite("PromoAppDTO Tests")
struct PromoAppDTOTests {

    @Test("DTO decodes valid JSON correctly")
    func decodesValidJSON() throws {
        let json = """
        {
            "id": "test",
            "title": "Test App",
            "short_description": "Description",
            "image_url": "https://example.com/image.png",
            "destination_url": "https://apps.apple.com/app/123",
            "is_featured": true,
            "sort_order": 5
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder().decode(PromoAppDTO.self, from: json)

        #expect(dto.id == "test")
        #expect(dto.title == "Test App")
        #expect(dto.shortDescription == "Description")
        #expect(dto.imageURL == "https://example.com/image.png")
        #expect(dto.destinationURL == "https://apps.apple.com/app/123")
        #expect(dto.isFeatured == true)
        #expect(dto.sortOrder == 5)
    }

    @Test("DTO decodes JSON without optional fields")
    func decodesMinimalJSON() throws {
        let json = """
        {
            "id": "minimal",
            "title": "Minimal",
            "short_description": "No optionals",
            "image_url": "https://example.com/image.png",
            "destination_url": "https://apps.apple.com/app/1"
        }
        """.data(using: .utf8)!

        let dto = try JSONDecoder().decode(PromoAppDTO.self, from: json)

        #expect(dto.id == "minimal")
        #expect(dto.isFeatured == nil)
        #expect(dto.sortOrder == nil)
    }

    @Test("PromoAppListDTO decodes array of apps")
    func listDTO_decodesApps() throws {
        let listDTO = try JSONDecoder().decode(PromoAppListDTO.self, from: TestData.validJSON)

        #expect(listDTO.apps.count == 2)
        #expect(listDTO.version == "1.0")
        #expect(listDTO.apps[0].id == "com.example.app1")
        #expect(listDTO.apps[1].id == "com.example.app2")
    }
}
