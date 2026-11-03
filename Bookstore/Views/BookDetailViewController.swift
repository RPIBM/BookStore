import UIKit

final class BookDetailViewController: UIViewController {

    private let book: Book
    private let cart: CartStore
    private let addButton = UIButton(type: .system)

    init(book: Book, cart: CartStore) {
        self.book = book
        self.cart = cart
        super.init(nibName: nil, bundle: nil)
        title = book.genre.rawValue
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.largeTitleDisplayMode = .never

        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scrollView)

        let bottomBar = makeBottomBar()
        bottomBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(bottomBar)

        let content = UIStackView(arrangedSubviews: makeContent())
        content.axis = .vertical
        content.spacing = 12
        content.alignment = .fill
        content.isLayoutMarginsRelativeArrangement = true
        content.layoutMargins = UIEdgeInsets(top: 16, left: 20, bottom: 24, right: 20)
        content.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(content)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomBar.topAnchor),

            bottomBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),

            content.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            content.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            content.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            content.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            content.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor)
        ])

        NotificationCenter.default.addObserver(
            self, selector: #selector(refreshAddButton), name: .cartDidChange, object: cart)
        refreshAddButton()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private func makeContent() -> [UIView] {
        let cover = BookCoverView()
        cover.configure(with: book)
        cover.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cover.widthAnchor.constraint(equalToConstant: 180),
            cover.heightAnchor.constraint(equalToConstant: 260)
        ])
        let coverRow = UIStackView(arrangedSubviews: [UIView(), cover, UIView()])
        coverRow.distribution = .equalCentering

        let title = UILabel()
        title.text = book.title
        title.font = .systemFont(ofSize: 24, weight: .bold)
        title.textColor = Theme.textPrimary
        title.numberOfLines = 0
        title.textAlignment = .center

        let author = UILabel()
        author.text = "by \(book.author)"
        author.font = .systemFont(ofSize: 16)
        author.textColor = Theme.textSecondary
        author.textAlignment = .center

        let rating = UILabel()
        rating.text = "★ \(String(format: "%.1f", book.rating))  ·  \(book.pageCount) pages  ·  \(book.publishedYear)"
        rating.font = .systemFont(ofSize: 13)
        rating.textColor = Theme.star
        rating.textAlignment = .center
        rating.accessibilityLabel = "Rated \(book.rating) stars, \(book.pageCount) pages, published \(book.publishedYear)"

        let synopsisHeading = UILabel()
        synopsisHeading.text = "About this book"
        synopsisHeading.font = .systemFont(ofSize: 17, weight: .bold)
        synopsisHeading.textColor = Theme.textPrimary
        synopsisHeading.accessibilityTraits = .header

        let synopsis = UILabel()
        synopsis.text = book.synopsis
        synopsis.font = .systemFont(ofSize: 15)
        synopsis.textColor = Theme.textSecondary
        synopsis.numberOfLines = 0

        return [coverRow, title, author, rating, synopsisHeading, synopsis]
    }

    private func makeBottomBar() -> UIView {
        let bar = UIView()
        bar.backgroundColor = .white

        let border = UIView()
        border.backgroundColor = Theme.border
        border.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(border)

        let price = UILabel()
        price.text = book.price.asCurrency
        price.font = .systemFont(ofSize: 22, weight: .bold)
        price.textColor = Theme.textPrimary
        price.setContentHuggingPriority(.required, for: .horizontal)

        addButton.setTitleColor(.white, for: .normal)
        addButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        addButton.backgroundColor = Theme.accent
        addButton.layer.cornerRadius = 10
        addButton.addTarget(self, action: #selector(addToCartTapped), for: .touchUpInside)
        addButton.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let row = UIStackView(arrangedSubviews: [price, addButton])
        row.spacing = 16
        row.alignment = .center
        row.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(row)

        NSLayoutConstraint.activate([
            border.topAnchor.constraint(equalTo: bar.topAnchor),
            border.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: bar.trailingAnchor),
            border.heightAnchor.constraint(equalToConstant: 1),

            row.topAnchor.constraint(equalTo: bar.topAnchor, constant: 12),
            row.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 20),
            row.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -20),
            row.bottomAnchor.constraint(equalTo: bar.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        return bar
    }

    @objc private func refreshAddButton() {
        let inCart = cart.quantity(of: book)
        let atLimit = inCart >= CartStore.maxQuantityPerItem
        addButton.setTitle(
            atLimit ? "Maximum in cart" : (inCart > 0 ? "Add another (\(inCart) in cart)" : "Add to cart"),
            for: .normal)
        addButton.isEnabled = !atLimit
        addButton.alpha = atLimit ? 0.5 : 1
    }

    @objc private func addToCartTapped() {
        cart.add(book)
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        UIAccessibility.post(notification: .announcement, argument: "\(book.title) added to cart")
    }
}
