import XCTest
@testable import Bookstore

final class CartStoreTests: XCTestCase {

    private let repository = MockBookRepository()

    private func book(_ id: String) -> Book {
        guard let book = repository.book(withID: id) else {
            preconditionFailure("Missing fixture book \(id)")
        }
        return book
    }

    func testAddingSameBookIncrementsQuantity() {
        let cart = CartStore()
        cart.add(book("b01"))
        cart.add(book("b01"), quantity: 2)
        XCTAssertEqual(cart.items.count, 1)
        XCTAssertEqual(cart.quantity(of: book("b01")), 3)
        XCTAssertEqual(cart.totalQuantity, 3)
    }

    func testQuantityIsCappedAtMaximum() {
        let cart = CartStore()
        cart.add(book("b01"), quantity: 50)
        XCTAssertEqual(cart.quantity(of: book("b01")), CartStore.maxQuantityPerItem)
        cart.add(book("b01"))
        XCTAssertEqual(cart.quantity(of: book("b01")), CartStore.maxQuantityPerItem)
    }

    func testIgnoresNonPositiveAdd() {
        let cart = CartStore()
        cart.add(book("b01"), quantity: 0)
        cart.add(book("b01"), quantity: -3)
        XCTAssertTrue(cart.isEmpty)
    }

    func testSetQuantityToZeroRemovesItem() {
        let cart = CartStore()
        cart.add(book("b01"), quantity: 2)
        cart.setQuantity(0, for: book("b01"))
        XCTAssertTrue(cart.isEmpty)
    }

    func testSubtotalUsesExactDecimalMath() {
        let cart = CartStore()
        cart.add(book("b01"), quantity: 3)   // 14.99 x 3
        cart.add(book("b09"))                // 11.99
        XCTAssertEqual(cart.subtotal, Decimal(string: "56.96"))
    }

    func testPostsNotificationOnChange() {
        let cart = CartStore()
        let expectation = expectation(forNotification: .cartDidChange, object: cart)
        cart.add(book("b01"))
        wait(for: [expectation], timeout: 1)
    }

    func testRemoveAndClear() {
        let cart = CartStore()
        cart.add(book("b01"))
        cart.add(book("b02"))
        cart.remove(book("b01"))
        XCTAssertEqual(cart.items.map(\.book.id), ["b02"])
        cart.clear()
        XCTAssertTrue(cart.isEmpty)
    }
}

final class CheckoutServiceTests: XCTestCase {

    private let validDetails = ShippingDetails(
        fullName: "Ada Lovelace", email: "ada@example.com",
        street: "12 Analytical Way", city: "London", postalCode: "N1 9GU")

    private var sampleItems: [CartItem] {
        guard let book = MockBookRepository().book(withID: "b01") else { return [] }
        return [CartItem(book: book, quantity: 1)]
    }

    func testShippingIsFreeAtThresholdAndForEmptyCart() {
        XCTAssertEqual(CheckoutService.shippingCost(for: 0), 0)
        XCTAssertEqual(CheckoutService.shippingCost(for: 35), 0)
        XCTAssertEqual(CheckoutService.shippingCost(for: 34.99), CheckoutService.flatShipping)
    }

    func testEmailValidation() {
        XCTAssertTrue(CheckoutService.isValidEmail("a.b+c@example.co"))
        XCTAssertFalse(CheckoutService.isValidEmail("no-at-sign.com"))
        XCTAssertFalse(CheckoutService.isValidEmail("a@b"))
        XCTAssertFalse(CheckoutService.isValidEmail(""))
    }

    func testPostalCodeValidation() {
        XCTAssertTrue(CheckoutService.isValidPostalCode("94105"))
        XCTAssertTrue(CheckoutService.isValidPostalCode("SW1A 1AA"))
        XCTAssertFalse(CheckoutService.isValidPostalCode("12"))
        XCTAssertFalse(CheckoutService.isValidPostalCode("<script>"))
    }

    func testFirstInvalidFieldReportsInOrder() {
        var details = validDetails
        XCTAssertNil(CheckoutService.firstInvalidField(in: details))

        details.email = "bad"
        XCTAssertEqual(CheckoutService.firstInvalidField(in: details), "Email")

        details.fullName = " "
        XCTAssertEqual(CheckoutService.firstInvalidField(in: details), "Full name")
    }

    func testPlaceOrderRejectsEmptyCart() {
        XCTAssertEqual(CheckoutService.placeOrder(items: [], shipping: validDetails), .failure(.emptyCart))
    }

    func testPlaceOrderRejectsInvalidDetails() {
        var details = validDetails
        details.city = ""
        XCTAssertEqual(
            CheckoutService.placeOrder(items: sampleItems, shipping: details),
            .failure(.invalidField("City")))
    }

    func testPlaceOrderTotalsIncludeShipping() {
        guard case .success(let order) = CheckoutService.placeOrder(items: sampleItems, shipping: validDetails) else {
            return XCTFail("Expected a successful order")
        }
        // 14.99 + 4.99 shipping
        XCTAssertEqual(order.total, Decimal(string: "19.98"))
        XCTAssertTrue(order.number.hasPrefix("BK-"))
    }
}
