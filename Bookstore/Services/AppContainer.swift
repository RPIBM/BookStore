import Foundation

/// Simple dependency container shared by all screens.
final class AppContainer {
    let repository: BookRepository
    let cart: CartStore

    init(repository: BookRepository = MockBookRepository(), cart: CartStore = CartStore()) {
        self.repository = repository
        self.cart = cart
    }
}
