import XCTest
@testable import Bookstore

final class BookQueryTests: XCTestCase {

    private let books = MockBookRepository().allBooks()

    func testDefaultQueryReturnsAllBooksInCatalogOrder() {
        let query = BookQuery()
        XCTAssertEqual(query.sorted(books.filter(query.matches)), books)
    }

    func testSearchMatchesTitleAuthorAndGenreCaseInsensitively() {
        XCTAssertEqual(results(for: BookQuery(searchText: "dune")).map(\.id), ["b04"])
        XCTAssertEqual(results(for: BookQuery(searchText: "TOLKIEN")).map(\.id), ["b09"])
        XCTAssertTrue(results(for: BookQuery(searchText: "mystery")).allSatisfy { $0.genre == .mystery })
    }

    func testSearchWithNoMatchReturnsEmpty() {
        XCTAssertTrue(results(for: BookQuery(searchText: "zzzz-no-such-book")).isEmpty)
    }

    func testGenreFilterIsAnyOfSelected() {
        var query = BookQuery()
        query.genres = [.fantasy, .biography]
        let found = results(for: query)
        XCTAssertFalse(found.isEmpty)
        XCTAssertTrue(found.allSatisfy { [.fantasy, .biography].contains($0.genre) })
    }

    func testPriceBandBoundaries() {
        XCTAssertTrue(PriceBand.under15.contains(14.99))
        XCTAssertFalse(PriceBand.under15.contains(15))
        XCTAssertTrue(PriceBand.from15to25.contains(15))
        XCTAssertTrue(PriceBand.from15to25.contains(25))
        XCTAssertFalse(PriceBand.from15to25.contains(25.01))
        XCTAssertTrue(PriceBand.over25.contains(25.01))
    }

    func testBestsellerAndHighlyRatedFilters() {
        var query = BookQuery()
        query.bestsellersOnly = true
        XCTAssertTrue(results(for: query).allSatisfy { $0.isBestseller })

        query = BookQuery()
        query.highlyRatedOnly = true
        XCTAssertTrue(results(for: query).allSatisfy { $0.rating >= BookQuery.highlyRatedThreshold })
    }

    func testSortByPriceAndTitle() {
        var query = BookQuery()
        query.sort = .priceLowHigh
        let ascending = results(for: query).map(\.price)
        XCTAssertEqual(ascending, ascending.sorted())

        query.sort = .priceHighLow
        let descending = results(for: query).map(\.price)
        XCTAssertEqual(descending, descending.sorted(by: >))

        query.sort = .titleAZ
        let titles = results(for: query).map(\.title)
        XCTAssertEqual(titles, titles.sorted { $0.localizedCaseInsensitiveCompare($1) == .orderedAscending })
    }

    func testActiveFilterCountIgnoresSort() {
        var query = BookQuery()
        query.sort = .topRated
        XCTAssertEqual(query.activeFilterCount, 0)
        XCTAssertTrue(query.hasCustomSortOrFilter)

        query.genres = [.fiction, .mystery]
        query.bestsellersOnly = true
        XCTAssertEqual(query.activeFilterCount, 3)
    }

    private func results(for query: BookQuery) -> [Book] {
        query.sorted(books.filter(query.matches))
    }
}

final class CatalogViewModelTests: XCTestCase {

    func testFeaturedSectionOnlyOnDefaultView() {
        let model = CatalogViewModel(repository: MockBookRepository())
        XCTAssertTrue(model.showsFeaturedSection)

        model.query.searchText = "dune"
        XCTAssertFalse(model.showsFeaturedSection)

        model.query.searchText = ""
        model.query.sort = .titleAZ
        XCTAssertFalse(model.showsFeaturedSection)
    }

    func testOnChangeFiresOnlyWhenQueryChanges() {
        let model = CatalogViewModel(repository: MockBookRepository())
        var calls = 0
        model.onChange = { calls += 1 }

        model.query.searchText = "dune"
        model.query.searchText = "dune"
        XCTAssertEqual(calls, 1)
    }

    func testResultsTitlePluralisation() {
        let model = CatalogViewModel(repository: MockBookRepository())
        XCTAssertEqual(model.resultsTitle, "All Books")
        model.query.searchText = "dune"
        XCTAssertEqual(model.resultsTitle, "1 result")
        model.query.searchText = "fantasy"
        XCTAssertTrue(model.resultsTitle.hasSuffix("results"))
    }
}
