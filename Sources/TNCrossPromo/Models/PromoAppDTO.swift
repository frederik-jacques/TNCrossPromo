import Foundation

/// Internal data transfer object matching the remote JSON structure
struct PromoAppDTO: Codable, Sendable {
    let id: String
    let title: String
    let shortDescription: String
    let imageURL: String
    let destinationURL: String
    let isFeatured: Bool?
    let sortOrder: Int?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case shortDescription = "short_description"
        case imageURL = "image_url"
        case destinationURL = "destination_url"
        case isFeatured = "is_featured"
        case sortOrder = "sort_order"
    }
}

/// Root response object for the JSON feed
struct PromoAppListDTO: Codable, Sendable {
    let apps: [PromoAppDTO]
    let version: String?
}
