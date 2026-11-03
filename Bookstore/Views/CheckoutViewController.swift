import UIKit

final class CheckoutViewController: UIViewController, UITextFieldDelegate {

    private let cart: CartStore
    private let scrollView = UIScrollView()
    private let nameField = UITextField()
    private let emailField = UITextField()
    private let streetField = UITextField()
    private let cityField = UITextField()
    private let postalField = UITextField()
    private let totalLabel = UILabel()
    private lazy var fields: [UITextField] = [nameField, emailField, streetField, cityField, postalField]

    init(cart: CartStore) {
        self.cart = cart
        super.init(nibName: nil, bundle: nil)
        title = "Checkout"
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never

        scrollView.keyboardDismissMode = .interactive
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        configureField(nameField, placeholder: "Full name", content: .name, keyboard: .default, capitalize: .words)
        configureField(emailField, placeholder: "Email", content: .emailAddress, keyboard: .emailAddress, capitalize: .none)
        configureField(streetField, placeholder: "Street address", content: .streetAddressLine1, keyboard: .default, capitalize: .words)
        configureField(cityField, placeholder: "City", content: .addressCity, keyboard: .default, capitalize: .words)
        configureField(postalField, placeholder: "Postal code", content: .postalCode, keyboard: .numbersAndPunctuation, capitalize: .allCharacters)
        fields.enumerated().forEach { index, field in
            field.returnKeyType = index == fields.count - 1 ? .done : .next
        }

        let subtotal = cart.subtotal
        let shipping = CheckoutService.shippingCost(for: subtotal)
        totalLabel.text = "Order total: \((subtotal + shipping).asCurrency)"
        totalLabel.font = .systemFont(ofSize: 17, weight: .bold)
        totalLabel.textColor = Theme.textPrimary

        let note = UILabel()
        note.text = shipping == 0
            ? "Free shipping applied."
            : "Add \((CheckoutService.freeShippingThreshold - subtotal).asCurrency) more for free shipping."
        note.font = .systemFont(ofSize: 12)
        note.textColor = Theme.textSecondary

        let heading = UILabel()
        heading.text = "Shipping details"
        heading.font = .systemFont(ofSize: 18, weight: .bold)
        heading.textColor = Theme.textPrimary
        heading.accessibilityTraits = .header

        let placeOrder = UIButton(type: .system)
        placeOrder.setTitle("Place order", for: .normal)
        placeOrder.setTitleColor(.white, for: .normal)
        placeOrder.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        placeOrder.backgroundColor = Theme.accent
        placeOrder.layer.cornerRadius = 10
        placeOrder.heightAnchor.constraint(equalToConstant: 48).isActive = true
        placeOrder.addTarget(self, action: #selector(placeOrderTapped), for: .touchUpInside)

        let stack = UIStackView(arrangedSubviews: [heading] + fields + [totalLabel, note, placeOrder])
        stack.axis = .vertical
        stack.spacing = 12
        stack.setCustomSpacing(20, after: fields[fields.count - 1])
        stack.setCustomSpacing(4, after: totalLabel)
        stack.setCustomSpacing(20, after: note)
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 20, left: 20, bottom: 24, right: 20)
        stack.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(stack)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor),

            stack.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stack.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            stack.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])
    }

    private func configureField(
        _ field: UITextField,
        placeholder: String,
        content: UITextContentType,
        keyboard: UIKeyboardType,
        capitalize: UITextAutocapitalizationType
    ) {
        field.placeholder = placeholder
        field.textContentType = content
        field.keyboardType = keyboard
        field.autocapitalizationType = capitalize
        field.autocorrectionType = .no
        field.borderStyle = .none
        field.layer.cornerRadius = 8
        field.layer.borderWidth = 1.2
        field.layer.borderColor = Theme.border.cgColor
        field.font = .systemFont(ofSize: 15)
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        field.leftViewMode = .always
        field.heightAnchor.constraint(equalToConstant: 48).isActive = true
        field.accessibilityLabel = placeholder
        field.delegate = self
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let index = fields.firstIndex(of: textField), index < fields.count - 1 {
            fields[index + 1].becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }

    @objc private func placeOrderTapped() {
        view.endEditing(true)
        let details = ShippingDetails(
            fullName: nameField.text ?? "",
            email: emailField.text ?? "",
            street: streetField.text ?? "",
            city: cityField.text ?? "",
            postalCode: postalField.text ?? "")

        switch CheckoutService.placeOrder(items: cart.items, shipping: details) {
        case .success(let order):
            cart.clear()
            let confirmation = OrderConfirmationViewController(order: order)
            // Keep the cart root in the stack so "Continue shopping" can pop back to it.
            if let root = navigationController?.viewControllers.first {
                navigationController?.setViewControllers([root, confirmation], animated: true)
            }
        case .failure(.emptyCart):
            presentAlert(title: "Cart is empty", message: "Add a book before checking out.")
        case .failure(.invalidField(let name)):
            presentAlert(title: "Check your details", message: "Please enter a valid \(name.lowercased()).")
        }
    }
}
