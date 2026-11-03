import Foundation

enum Genre: String, CaseIterable, Hashable {
    case fiction = "Fiction"
    case mystery = "Mystery"
    case scienceFiction = "Science Fiction"
    case fantasy = "Fantasy"
    case nonFiction = "Non-Fiction"
    case biography = "Biography"
}

struct Book: Hashable, Identifiable {
    let id: String
    let title: String
    let author: String
    let genre: Genre
    let synopsis: String
    let price: Decimal
    let rating: Double
    let pageCount: Int
    let publishedYear: Int
    let isBestseller: Bool
    /// Two RGB hex values (0xRRGGBB) used to paint the generated cover gradient.
    let coverColors: [UInt32]
}
