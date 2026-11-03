import UIKit

final class MainTabBarController: UITabBarController {

    private let container: AppContainer

    init(container: AppContainer) {
        self.container = container
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()

        let catalog = makeNavigation(CatalogViewController(container: container), largeTitles: true)
        let cart = makeNavigation(CartViewController(cart: container.cart), largeTitles: false)
        viewControllers = [catalog, cart]

        tabBar.tintColor = Theme.accent
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance

        NotificationCenter.default.addObserver(
            self, selector: #selector(updateCartBadge), name: .cartDidChange, object: container.cart)
        updateCartBadge()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func makeNavigation(_ root: UIViewController, largeTitles: Bool) -> UINavigationController {
        let navigation = UINavigationController(rootViewController: root)
        let appearance = Theme.styleNavigationBar()
        navigation.navigationBar.standardAppearance = appearance
        navigation.navigationBar.scrollEdgeAppearance = appearance
        navigation.navigationBar.compactAppearance = appearance
        navigation.navigationBar.tintColor = .white
        navigation.navigationBar.prefersLargeTitles = largeTitles
        navigation.tabBarItem = root.tabBarItem
        return navigation
    }

    @objc private func updateCartBadge() {
        let count = container.cart.totalQuantity
        viewControllers?.last?.tabBarItem.badgeValue = count > 0 ? String(count) : nil
    }
}
