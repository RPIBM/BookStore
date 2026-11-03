import UIKit

final class CartViewController: UIViewController {

    private let cart: CartStore
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let emptyStack = UIStackView()
    private let summaryBar = UIView()
    private let subtotalLabel = UILabel()
    private let shippingLabel = UILabel()
    private let totalLabel = UILabel()
    private let checkoutButton = UIButton(type: .system)

    init(cart: CartStore) {
        self.cart = cart
        super.init(nibName: nil, bundle: nil)
        title = "Cart"
        tabBarItem = UITabBarItem(title: "Cart", image: UIImage(systemName: "cart"), tag: 1)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        tableView.dataSource = self
        tableView.register(CartItemCell.self, forCellReuseIdentifier: CartItemCell.reuseIdentifier)
        tableView.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        tableView.tableFooterView = UIView()
        view.addSubview(tableView)

        buildEmptyState()
        buildSummaryBar()

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: summaryBar.topAnchor)
        ])

        NotificationCenter.default.addObserver(
            self, selector: #selector(cartChanged), name: .cartDidChange, object: cart)
        refresh()
    }

    private func buildEmptyState() {
        let icon = UIImageView(image: UIImage(systemName: "cart"))
        icon.tintColor = Theme.border
        icon.contentMode = .scaleAspectFit
        icon.heightAnchor.constraint(equalToConstant: 64).isActive = true

        let title = UILabel()
        title.text = "Your cart is empty"
        title.font = .systemFont(ofSize: 18, weight: .semibold)
        title.textColor = Theme.textPrimary

        let message = UILabel()
        message.text = "Browse the catalog and add a book you love."
        message.font = .systemFont(ofSize: 14)
        message.textColor = Theme.textSecondary

        [icon, title, message].forEach(emptyStack.addArrangedSubview)
        emptyStack.axis = .vertical
        emptyStack.alignment = .center
        emptyStack.spacing = 8
        emptyStack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyStack)
        NSLayoutConstraint.activate([
            emptyStack.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyStack.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func buildSummaryBar() {
        summaryBar.backgroundColor = .white
        summaryBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(summaryBar)

        let border = UIView()
        border.backgroundColor = Theme.border
        border.translatesAutoresizingMaskIntoConstraints = false
        summaryBar.addSubview(border)

        let subtotalRow = makeRow(title: "Subtotal", value: subtotalLabel, bold: false)
        let shippingRow = makeRow(title: "Shipping", value: shippingLabel, bold: false)
        let totalRow = makeRow(title: "Total", value: totalLabel, bold: true)

        checkoutButton.setTitle("Checkout", for: .normal)
        checkoutButton.setTitleColor(.white, for: .normal)
        checkoutButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        checkoutButton.backgroundColor = Theme.accent
        checkoutButton.layer.cornerRadius = 10
        checkoutButton.addTarget(self, action: #selector(checkoutTapped), for: .touchUpInside)
        checkoutButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let stack = UIStackView(arrangedSubviews: [subtotalRow, shippingRow, totalRow, checkoutButton])
        stack.axis = .vertical
        stack.spacing = 6
        stack.setCustomSpacing(12, after: totalRow)
        stack.translatesAutoresizingMaskIntoConstraints = false
        summaryBar.addSubview(stack)

        NSLayoutConstraint.activate([
            summaryBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            summaryBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            summaryBar.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

            border.topAnchor.constraint(equalTo: summaryBar.topAnchor),
            border.leadingAnchor.constraint(equalTo: summaryBar.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: summaryBar.trailingAnchor),
            border.heightAnchor.constraint(equalToConstant: 1),

            stack.topAnchor.constraint(equalTo: summaryBar.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: summaryBar.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: summaryBar.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: summaryBar.bottomAnchor, constant: -8)
        ])
    }

    private func makeRow(title: String, value: UILabel, bold: Bool) -> UIView {
        let label = UILabel()
        label.text = title
        let weight: UIFont.Weight = bold ? .bold : .regular
        label.font = .systemFont(ofSize: bold ? 17 : 14, weight: weight)
        label.textColor = bold ? Theme.textPrimary : Theme.textSecondary
        value.font = .systemFont(ofSize: bold ? 17 : 14, weight: weight)
        value.textColor = Theme.textPrimary
        value.textAlignment = .right
        return UIStackView(arrangedSubviews: [label, value])
    }

    @objc private func cartChanged() {
        refresh()
    }

    private func refresh() {
        let subtotal = cart.subtotal
        let shipping = CheckoutService.shippingCost(for: subtotal)
        subtotalLabel.text = subtotal.asCurrency
        shippingLabel.text = shipping == 0 ? "Free" : shipping.asCurrency
        totalLabel.text = (subtotal + shipping).asCurrency

        emptyStack.isHidden = !cart.isEmpty
        tableView.isHidden = cart.isEmpty
        summaryBar.isHidden = cart.isEmpty
        tableView.reloadData()
    }

    @objc private func checkoutTapped() {
        let checkout = CheckoutViewController(cart: cart)
        navigationController?.pushViewController(checkout, animated: true)
    }
}

extension CartViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        cart.items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CartItemCell.reuseIdentifier, for: indexPath)
        let item = cart.items[indexPath.row]
        if let cartCell = cell as? CartItemCell {
            cartCell.configure(with: item)
            cartCell.onQuantityChange = { [weak self] quantity in
                self?.cart.setQuantity(quantity, for: item.book)
            }
        }
        return cell
    }

    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool { true }

    func tableView(
        _ tableView: UITableView,
        commit editingStyle: UITableViewCell.EditingStyle,
        forRowAt indexPath: IndexPath
    ) {
        if editingStyle == .delete {
            cart.remove(cart.items[indexPath.row].book)
        }
    }
}
