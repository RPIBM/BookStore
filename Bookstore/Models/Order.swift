import Foundation

struct CartItem: Equatable {
    let book: Book
    var quantity: Int

    var lineTotal: Decimal {
        book.price * Decimal(quantity)
    }
}

struct ShippingDetails: Equatable {
    var fullName: String
    var email: String
    var street: String
    var city: String
    var postalCode: String
}

struct Order: Equatable {
    let number: String
    let items: [CartItem]
    let shipping: ShippingDetails
    let total: Decimal
    let placedAt: Date
}

extension Decimal {
    /// Formats the value as US dollars, e.g. "$12.99".
    var asCurrency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale(identifier: "en_US")
        formatter.currencyCode = "USD"
        return formatter.string(from: self as NSDecimalNumber) ?? "$\(self)"
    }
}
