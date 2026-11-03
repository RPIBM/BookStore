import Foundation

extension Notification.Name {
    static let cartDidChange = Notification.Name("CartStore.cartDidChange")
}

/// Holds the shopping cart and posts `.cartDidChange` after every mutation.
final class CartStore {

    static let maxQuantityPerItem = 10

    private(set) var items: [CartItem] = [] {
        didSet { NotificationCenter.default.post(name: .cartDidChange, object: self) }
    }

    var totalQuantity: Int {
        items.reduce(0) { $0 + $1.quantity }
    }

    var subtotal: Decimal {
        items.reduce(0) { $0 + $1.lineTotal }
    }

    var isEmpty: Bool { items.isEmpty }

    func quantity(of book: Book) -> Int {
        items.first { $0.book.id == book.id }?.quantity ?? 0
    }

    func add(_ book: Book, quantity: Int = 1) {
        guard quantity > 0 else { return }
        if let index = items.firstIndex(where: { $0.book.id == book.id }) {
            let updated = min(items[index].quantity + quantity, Self.maxQuantityPerItem)
            items[index].quantity = updated
        } else {
            items.append(CartItem(book: book, quantity: min(quantity, Self.maxQuantityPerItem)))
        }
    }

    func setQuantity(_ quantity: Int, for book: Book) {
        guard let index = items.firstIndex(where: { $0.book.id == book.id }) else { return }
        if quantity <= 0 {
            items.remove(at: index)
        } else {
            items[index].quantity = min(quantity, Self.maxQuantityPerItem)
        }
    }

    func remove(_ book: Book) {
        items.removeAll { $0.book.id == book.id }
    }

    func clear() {
        items.removeAll()
    }
}
