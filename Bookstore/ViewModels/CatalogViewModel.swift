import Foundation

/// Drives the catalog screen: applies the current query to the repository's books.
final class CatalogViewModel {

    private let repository: BookRepository

    var query = BookQuery() {
        didSet { if query != oldValue { onChange?() } }
    }

    var onChange: (() -> Void)?

    init(repository: BookRepository) {
        self.repository = repository
    }

    var books: [Book] {
        query.sorted(repository.allBooks().filter(query.matches))
    }

    var featuredBestsellers: [Book] {
        repository.allBooks().filter { $0.isBestseller }
    }

    /// The hero carousel is only shown on the unfiltered default view.
    var showsFeaturedSection: Bool {
        query.searchText.isEmpty && !query.hasCustomSortOrFilter
    }

    var resultsTitle: String {
        let count = books.count
        return showsFeaturedSection ? "All Books" : "\(count) \(count == 1 ? "result" : "results")"
    }
}
