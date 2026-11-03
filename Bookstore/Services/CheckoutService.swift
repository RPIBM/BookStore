import Foundation

enum CheckoutError: Error, Equatable {
    case emptyCart
    case invalidField(String)
}

/// Validates shipping details and turns the cart into an `Order`.
struct CheckoutService {

    static let flatShipping = Decimal(string: "4.99", locale: Locale(identifier: "en_US")) ?? 5
    static let freeShippingThreshold: Decimal = 35

    static func shippingCost(for subtotal: Decimal) -> Decimal {
        subtotal == 0 || subtotal >= freeShippingThreshold ? 0 : flatShipping
    }

    /// Returns the name of the first invalid field, or nil if all fields are valid.
    static func firstInvalidField(in details: ShippingDetails) -> String? {
        if details.fullName.trimmingCharacters(in: .whitespaces).count < 2 { return "Full name" }
        if !isValidEmail(details.email) { return "Email" }
        if details.street.trimmingCharacters(in: .whitespaces).count < 3 { return "Street address" }
        if details.city.trimmingCharacters(in: .whitespaces).count < 2 { return "City" }
        if !isValidPostalCode(details.postalCode) { return "Postal code" }
        return nil
    }

    static func isValidEmail(_ email: String) -> Bool {
        let pattern = "^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}$"
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    static func isValidPostalCode(_ code: String) -> Bool {
        code.range(of: "^[A-Za-z0-9 -]{3,10}$", options: .regularExpression) != nil
    }

    static func placeOrder(items: [CartItem], shipping: ShippingDetails) -> Result<Order, CheckoutError> {
        guard !items.isEmpty else { return .failure(.emptyCart) }
        if let field = firstInvalidField(in: shipping) { return .failure(.invalidField(field)) }

        let subtotal = items.reduce(Decimal(0)) { $0 + $1.lineTotal }
        let total = subtotal + shippingCost(for: subtotal)
        let number = "BK-" + String(Int.random(in: 100_000...999_999))
        return .success(Order(number: number, items: items, shipping: shipping, total: total, placedAt: Date()))
    }
}
