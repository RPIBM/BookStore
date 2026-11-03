import Foundation

enum SortOption: CaseIterable, Hashable {
    case featured
    case titleAZ
    case titleZA
    case priceLowHigh
    case priceHighLow
    case topRated

    var title: String {
        switch self {
        case .featured: return "Featured"
        case .titleAZ: return "Title: A – Z"
        case .titleZA: return "Title: Z – A"
        case .priceLowHigh: return "Price: Low to High"
        case .priceHighLow: return "Price: High to Low"
        case .topRated: return "Top Rated"
        }
    }

    var subtitle: String? {
        self == .featured ? "Default" : nil
    }
}

enum PriceBand: CaseIterable, Hashable {
    case under15
    case from15to25
    case over25

    var title: String {
        switch self {
        case .under15: return "Under $15"
        case .from15to25: return "$15 – $25"
        case .over25: return "Over $25"
        }
    }

    func contains(_ price: Decimal) -> Bool {
        switch self {
        case .under15: return price < 15
        case .from15to25: return price >= 15 && price <= 25
        case .over25: return price > 25
        }
    }
}

/// Describes what the catalog should show: search text, sort order and filters.
struct BookQuery: Equatable {
    static let highlyRatedThreshold = 4.5

    var searchText: String = ""
    var sort: SortOption = .featured
    var genres: Set<Genre> = []
    var priceBands: Set<PriceBand> = []
    var bestsellersOnly = false
    var highlyRatedOnly = false

    /// Number of active filters (sort order is not a filter).
    var activeFilterCount: Int {
        genres.count + priceBands.count + (bestsellersOnly ? 1 : 0) + (highlyRatedOnly ? 1 : 0)
    }

    var hasCustomSortOrFilter: Bool {
        sort != .featured || activeFilterCount > 0
    }

    func matches(_ book: Book) -> Bool {
        let term = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !term.isEmpty {
            let haystack = [book.title, book.author, book.genre.rawValue]
            guard haystack.contains(where: { $0.localizedCaseInsensitiveContains(term) }) else { return false }
        }
        if !genres.isEmpty, !genres.contains(book.genre) { return false }
        if !priceBands.isEmpty, !priceBands.contains(where: { $0.contains(book.price) }) { return false }
        if bestsellersOnly, !book.isBestseller { return false }
        if highlyRatedOnly, book.rating < Self.highlyRatedThreshold { return false }
        return true
    }

    func sorted(_ books: [Book]) -> [Book] {
        switch sort {
        case .featured:
            return books
        case .titleAZ:
            return books.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleZA:
            return books.sorted { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        case .priceLowHigh:
            return books.sorted { $0.price < $1.price }
        case .priceHighLow:
            return books.sorted { $0.price > $1.price }
        case .topRated:
            return books.sorted {
                $0.rating != $1.rating
                    ? $0.rating > $1.rating
                    : $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
            }
        }
    }
}
