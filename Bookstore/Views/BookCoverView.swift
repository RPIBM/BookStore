import UIKit

/// Shows the `cover_<id>` artwork from the asset catalog, falling back to a gradient
/// "cover" with the title and author when no artwork exists.
final class BookCoverView: UIView {

    private let gradient = CAGradientLayer()
    private let imageView = UIImageView()
    private let textStack = UIStackView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setUp()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setUp()
    }

    private func setUp() {
        layer.cornerRadius = 8
        clipsToBounds = true
        layer.insertSublayer(gradient, at: 0)
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)

        titleLabel.font = .systemFont(ofSize: 15, weight: .bold)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 4
        titleLabel.adjustsFontSizeToFitWidth = true
        titleLabel.minimumScaleFactor = 0.5

        authorLabel.font = .systemFont(ofSize: 11, weight: .medium)
        authorLabel.textColor = UIColor.white.withAlphaComponent(0.85)
        authorLabel.numberOfLines = 2
        authorLabel.adjustsFontSizeToFitWidth = true
        authorLabel.minimumScaleFactor = 0.6

        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(UIView())
        textStack.addArrangedSubview(authorLabel)
        textStack.axis = .vertical
        textStack.spacing = 4
        addSubview(textStack)
        textStack.pinEdges(to: self, insets: UIEdgeInsets(top: 10, left: 8, bottom: 8, right: 8))

        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        addSubview(imageView)
        imageView.pinEdges(to: self)

        isAccessibilityElement = false
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradient.frame = bounds
    }

    func configure(with book: Book) {
        let artwork = UIImage(named: "cover_\(book.id)")
        imageView.image = artwork
        imageView.isHidden = artwork == nil
        textStack.isHidden = artwork != nil

        let colors = book.coverColors.map { Theme.color(hex: $0).cgColor }
        gradient.colors = colors
        titleLabel.text = book.title
        authorLabel.text = book.author
    }
}
