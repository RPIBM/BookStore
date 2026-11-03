import UIKit

final class OrderConfirmationViewController: UIViewController {

    private let order: Order

    init(order: Order) {
        self.order = order
        super.init(nibName: nil, bundle: nil)
        title = "Order placed"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.hidesBackButton = true
        navigationItem.largeTitleDisplayMode = .never

        let icon = UIImageView(image: UIImage(systemName: "checkmark.circle.fill"))
        icon.tintColor = Theme.accent
        icon.contentMode = .scaleAspectFit
        icon.heightAnchor.constraint(equalToConstant: 72).isActive = true

        let heading = UILabel()
        heading.text = "Thank you, \(order.shipping.fullName)!"
        heading.font = .systemFont(ofSize: 22, weight: .bold)
        heading.textColor = Theme.textPrimary
        heading.textAlignment = .center
        heading.numberOfLines = 0

        let details = UILabel()
        let itemCount = order.items.reduce(0) { $0 + $1.quantity }
        details.text = """
        Order \(order.number)
        \(itemCount) \(itemCount == 1 ? "book" : "books") · \(order.total.asCurrency)
        Shipping to \(order.shipping.street), \(order.shipping.city) \(order.shipping.postalCode)
        A receipt was sent to \(order.shipping.email).
        """
        details.font = .systemFont(ofSize: 15)
        details.textColor = Theme.textSecondary
        details.textAlignment = .center
        details.numberOfLines = 0

        let button = UIButton(type: .system)
        button.setTitle("Continue shopping", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.backgroundColor = Theme.accent
        button.layer.cornerRadius = 10
        button.heightAnchor.constraint(equalToConstant: 48).isActive = true
        button.addTarget(self, action: #selector(continueTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [icon, heading, details, button])
        stack.axis = .vertical
        stack.spacing = 16
        stack.setCustomSpacing(28, after: details)
        stack.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            stack.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            stack.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24)
        ])

        UIAccessibility.post(notification: .screenChanged, argument: heading)
    }

    @objc private func continueTapped() {
        // Return the Cart tab to its (now empty) root, then switch to the Browse tab.
        navigationController?.popToRootViewController(animated: false)
        tabBarController?.selectedIndex = 0
    }
}
