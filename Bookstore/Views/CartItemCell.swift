import UIKit

final class CartItemCell: UITableViewCell {

    static let reuseIdentifier = "CartItemCell"

    var onQuantityChange: ((Int) -> Void)?

    private let cover = BookCoverView()
    private let titleLabel = UILabel()
    private let authorLabel = UILabel()
    private let priceLabel = UILabel()
    private let stepper = UIStepper()
    private let quantityLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none

        cover.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cover.widthAnchor.constraint(equalToConstant: 64),
            cover.heightAnchor.constraint(equalToConstant: 92)
        ])

        titleLabel.font = .systemFont(ofSize: 15, weight: .semibold)
        titleLabel.textColor = Theme.textPrimary
        titleLabel.numberOfLines = 2
        authorLabel.font = .systemFont(ofSize: 12)
        authorLabel.textColor = Theme.textSecondary
        priceLabel.font = .systemFont(ofSize: 15, weight: .bold)
        priceLabel.textColor = Theme.accent

        stepper.minimumValue = 0
        stepper.maximumValue = Double(CartStore.maxQuantityPerItem)
        stepper.addTarget(self, action: #selector(stepperChanged), for: .valueChanged)
        quantityLabel.font = .systemFont(ofSize: 14, weight: .medium)
        quantityLabel.textColor = Theme.textPrimary

        let stepperRow = UIStackView(arrangedSubviews: [stepper, quantityLabel, UIView()])
        stepperRow.axis = .horizontal
        stepperRow.spacing = 10
        stepperRow.alignment = .center

        let details = UIStackView(arrangedSubviews: [titleLabel, authorLabel, priceLabel, stepperRow])
        details.axis = .vertical
        details.spacing = 4

        let row = UIStackView(arrangedSubviews: [cover, details])
        row.axis = .horizontal
        row.spacing = 12
        row.alignment = .top
        contentView.addSubview(row)
        row.pinEdges(to: contentView, insets: UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    func configure(with item: CartItem) {
        cover.configure(with: item.book)
        titleLabel.text = item.book.title
        authorLabel.text = item.book.author
        priceLabel.text = item.lineTotal.asCurrency
        stepper.value = Double(item.quantity)
        quantityLabel.text = "Qty \(item.quantity)"
        stepper.accessibilityLabel = "Quantity of \(item.book.title)"
        stepper.accessibilityValue = "\(item.quantity)"
    }

    @objc private func stepperChanged() {
        onQuantityChange?(Int(stepper.value))
    }
}
