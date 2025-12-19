import Foundation

/// Public domain model for cross-promoted apps
public struct PromoApp: Identifiable, Sendable, Hashable {
    public let id: String
    public let title: String
    public let subtitle: String
    public let imageURL: URL
    public let destinationURL: URL
    public let isFeatured: Bool
    public let sortOrder: Int

    /// Allowed URL schemes for image URLs
    private static let allowedImageSchemes: Set<String> = ["https"]

    /// Allowed URL schemes for destination URLs (App Store links)
    private static let allowedDestinationSchemes: Set<String> = ["https", "itms-apps"]

    /// Creates a PromoApp from a DTO, returning nil if URLs are invalid or use disallowed schemes
    init?(dto: PromoAppDTO) {
        guard let imageURL = URL(string: dto.imageURL),
              let destinationURL = URL(string: dto.destinationURL),
              let imageScheme = imageURL.scheme?.lowercased(),
              let destinationScheme = destinationURL.scheme?.lowercased(),
              Self.allowedImageSchemes.contains(imageScheme),
              Self.allowedDestinationSchemes.contains(destinationScheme) else {
            return nil
        }
        self.id = dto.id
        self.title = dto.title
        self.subtitle = dto.shortDescription
        self.imageURL = imageURL
        self.destinationURL = destinationURL
        self.isFeatured = dto.isFeatured ?? false
        self.sortOrder = dto.sortOrder ?? Int.max
    }

    /// Public initializer for manual creation and testing
    public init(
        id: String,
        title: String,
        subtitle: String,
        imageURL: URL,
        destinationURL: URL,
        isFeatured: Bool = false,
        sortOrder: Int = 0
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.imageURL = imageURL
        self.destinationURL = destinationURL
        self.isFeatured = isFeatured
        self.sortOrder = sortOrder
    }
}
