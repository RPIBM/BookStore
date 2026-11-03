import UIKit

final class BookCell: UICollectionViewCell {

    static let reuseIdentifier = "BookCell"

    private let cover = BookCoverView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let ratingLabel = UILabel()
    private let priceLabel = UILabel()
    private let badgeLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        cover.translatesAutoresizingMaskIntoConstraints = false
        cover.heightAnchor.constraint(equalTo: cover.widthAnchor, multiplier: 1.45).isActive = true

        titleLabel.font = .systemFont(ofSize: 14, weight: .semibold)
        titleLabel.textColor = Theme.textPrimary
        titleLabel.numberOfLines = 2

        authorLabel.font = .systemFont(ofSize: 12)
        authorLabel.textColor = Theme.textSecondary

        ratingLabel.font = .systemFont(ofSize: 12)
        ratingLabel.textColor = Theme.star

        priceLabel.font = .systemFont(ofSize: 15, weight: .bold)
        priceLabel.textColor = Theme.accent

        badgeLabel.text = " BESTSELLER "
        badgeLabel.font = .systemFont(ofSize: 9, weight: .bold)
        badgeLabel.textColor = Theme.accent
        badgeLabel.backgroundColor = Theme.selectedFill
        badgeLabel.layer.cornerRadius = 8
        badgeLabel.layer.borderWidth = 0.8
        badgeLabel.layer.borderColor = Theme.accent.cgColor
        badgeLabel.clipsToBounds = true
        badgeLabel.textAlignment = .center
        badgeLabel.translatesAutoresizingMaskIntoConstraints = false
        badgeLabel.heightAnchor.constraint(equalToConstant: 16).isActive = true

        let badgeRow = UIStackView(arrangedSubviews: [badgeLabel, UIView()])
        badgeRow.axis = .horizontal

        let stack = UIStackView(arrangedSubviews: [cover, titleLabel, authorLabel, ratingLabel, priceLabel, badgeRow])
        stack.axis = .vertical
        stack.spacing = 4
        stack.setCustomSpacing(8, after: cover)
        stack.alignment = .fill
        contentView.addSubview(stack)

        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: contentView.topAnchor),
            stack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            stack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor)
        ])
    }

    func configure(with book: Book) {
        cover.configure(with: book)
        titleLabel.text = book.title
        authorLabel.text = book.author
        ratingLabel.text = "★ " + String(format: "%.1f", book.rating)
        priceLabel.text = book.price.asCurrency
        badgeLabel.isHidden = !book.isBestseller

        isAccessibilityElement = true
        accessibilityLabel = "\(book.title) by \(book.author), rated \(book.rating), \(book.price.asCurrency)"
        accessibilityTraits = .button
    }
}

/// Horizontal carousel cell used for the "Bestsellers" strip on the catalog screen.
final class FeaturedBooksCell: UICollectionViewCell, UICollectionViewDataSource, UICollectionViewDelegate {

    static let reuseIdentifier = "FeaturedBooksCell"

    var onSelect: ((Book) -> Void)?
    private var books: [Book] = []
    private let titleLabel = UILabel()
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 110, height: 160)
        layout.minimumLineSpacing = 12
        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.backgroundColor = .clear
        view.showsHorizontalScrollIndicator = false
        view.dataSource = self
        view.delegate = self
        view.register(FeaturedCoverCell.self, forCellWithReuseIdentifier: FeaturedCoverCell.reuseIdentifier)
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        titleLabel.text = "Bestsellers"
        titleLabel.font = .systemFont(ofSize: 18, weight: .bold)
        titleLabel.textColor = Theme.textPrimary
        titleLabel.accessibilityTraits = .header

        contentView.addSubview(titleLabel)
        contentView.addSubview(collectionView)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            collectionView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 160)
        ])
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    func configure(with books: [Book]) {
        self.books = books
        collectionView.reloadData()
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        books.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedCoverCell.reuseIdentifier, for: indexPath)
        (cell as? FeaturedCoverCell)?.configure(with: books[indexPath.item])
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        onSelect?(books[indexPath.item])
    }
}

private final class FeaturedCoverCell: UICollectionViewCell {
    static let reuseIdentifier = "FeaturedCoverCell"
    private let cover = BookCoverView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(cover)
        cover.pinEdges(to: contentView)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    func configure(with book: Book) {
        cover.configure(with: book)
        isAccessibilityElement = true
        accessibilityLabel = "Bestseller: \(book.title) by \(book.author)"
        accessibilityTraits = .button
    }
}

final class SectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "SectionHeaderView"
    let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = Theme.textPrimary
        label.accessibilityTraits = .header
        addSubview(label)
        label.pinEdges(to: self, insets: UIEdgeInsets(top: 12, left: 8, bottom: 4, right: 8))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }
}
