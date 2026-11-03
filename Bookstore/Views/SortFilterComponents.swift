import UIKit

/// Radio-style row used in the "Sort by" section.
final class SortOptionRow: UIControl {

    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let indicator = UIView()
    private let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))

    init(title: String, subtitle: String?) {
        super.init(frame: .zero)

        titleLabel.text = title
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = Theme.textSecondary
        subtitleLabel.isHidden = subtitle == nil

        indicator.layer.cornerRadius = 12
        indicator.layer.borderWidth = 1.5
        indicator.translatesAutoresizingMaskIntoConstraints = false
        checkmark.tintColor = .white
        checkmark.contentMode = .scaleAspectFit
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        indicator.addSubview(checkmark)
        NSLayoutConstraint.activate([
            indicator.widthAnchor.constraint(equalToConstant: 24),
            indicator.heightAnchor.constraint(equalToConstant: 24),
            checkmark.centerXAnchor.constraint(equalTo: indicator.centerXAnchor),
            checkmark.centerYAnchor.constraint(equalTo: indicator.centerYAnchor),
            checkmark.widthAnchor.constraint(equalToConstant: 12),
            checkmark.heightAnchor.constraint(equalToConstant: 12)
        ])

        let text = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel])
        text.axis = .vertical
        text.spacing = 2

        let row = UIStackView(arrangedSubviews: [text, indicator])
        row.alignment = .center
        row.spacing = 12
        row.isUserInteractionEnabled = false
        addSubview(row)
        row.pinEdges(to: self, insets: UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0))

        isAccessibilityElement = true
        accessibilityLabel = [title, subtitle].compactMap { $0 }.joined(separator: ", ")
        updateAppearance()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override var isSelected: Bool {
        didSet { updateAppearance() }
    }

    private func updateAppearance() {
        titleLabel.font = .systemFont(ofSize: 15, weight: isSelected ? .semibold : .regular)
        titleLabel.textColor = isSelected ? Theme.accent : Theme.textPrimary
        indicator.backgroundColor = isSelected ? Theme.accent : .clear
        indicator.layer.borderColor = (isSelected ? Theme.accent : Theme.border).cgColor
        checkmark.isHidden = !isSelected
        accessibilityTraits = isSelected ? [.button, .selected] : .button
    }
}

/// A "Filter by" row with title, optional POPULAR badge, description and a switch.
/// Hide the whole row with `isHidden` when the filter does not apply.
final class FilterToggleRow: UIView {

    var onChange: ((Bool) -> Void)?

    var isOn: Bool {
        get { toggle.isOn }
        set { toggle.isOn = newValue }
    }

    private let toggle = UISwitch()

    init(title: String, subtitle: String, showsPopularBadge: Bool) {
        super.init(frame: .zero)

        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 15, weight: .medium)
        titleLabel.textColor = Theme.textPrimary

        let badge = UILabel()
        badge.text = "POPULAR"
        badge.font = .systemFont(ofSize: 9, weight: .bold)
        badge.textColor = Theme.accent
        badge.textAlignment = .center
        badge.backgroundColor = Theme.selectedFill
        badge.layer.cornerRadius = 9
        badge.layer.borderWidth = 0.8
        badge.layer.borderColor = Theme.accent.cgColor
        badge.clipsToBounds = true
        badge.isHidden = !showsPopularBadge
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.setContentHuggingPriority(.required, for: .horizontal)
        NSLayoutConstraint.activate([
            badge.heightAnchor.constraint(equalToConstant: 18),
            badge.widthAnchor.constraint(equalToConstant: 60)
        ])

        let titleRow = UIStackView(arrangedSubviews: [titleLabel, badge, UIView()])
        titleRow.spacing = 8
        titleRow.alignment = .center

        let subtitleLabel = UILabel()
        subtitleLabel.text = subtitle
        subtitleLabel.font = .systemFont(ofSize: 12)
        subtitleLabel.textColor = Theme.textSecondary
        subtitleLabel.numberOfLines = 0

        let text = UIStackView(arrangedSubviews: [titleRow, subtitleLabel])
        text.axis = .vertical
        text.spacing = 4

        toggle.onTintColor = Theme.accent
        toggle.accessibilityLabel = title
        toggle.addTarget(self, action: #selector(toggleChanged), for: .valueChanged)
        toggle.setContentHuggingPriority(.required, for: .horizontal)

        let row = UIStackView(arrangedSubviews: [text, toggle])
        row.alignment = .center
        row.spacing = 12
        addSubview(row)
        row.pinEdges(to: self, insets: UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0))
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    @objc private func toggleChanged() {
        onChange?(toggle.isOn)
    }
}

/// Bordered checkbox chip used for genre and price selections.
final class CheckboxChip: UIControl {

    private let titleLabel = UILabel()
    private let box = UIView()
    private let checkmark = UIImageView(image: UIImage(systemName: "checkmark"))

    init(title: String) {
        super.init(frame: .zero)

        layer.cornerRadius = 8
        layer.borderWidth = 1.2

        titleLabel.text = title
        titleLabel.numberOfLines = 2

        box.layer.cornerRadius = 4
        box.layer.borderWidth = 1.5
        box.translatesAutoresizingMaskIntoConstraints = false
        checkmark.tintColor = .white
        checkmark.contentMode = .scaleAspectFit
        checkmark.translatesAutoresizingMaskIntoConstraints = false
        box.addSubview(checkmark)
        NSLayoutConstraint.activate([
            box.widthAnchor.constraint(equalToConstant: 18),
            box.heightAnchor.constraint(equalToConstant: 18),
            checkmark.centerXAnchor.constraint(equalTo: box.centerXAnchor),
            checkmark.centerYAnchor.constraint(equalTo: box.centerYAnchor),
            checkmark.widthAnchor.constraint(equalToConstant: 11),
            checkmark.heightAnchor.constraint(equalToConstant: 11)
        ])

        let row = UIStackView(arrangedSubviews: [box, titleLabel])
        row.spacing = 10
        row.alignment = .center
        row.isUserInteractionEnabled = false
        addSubview(row)
        row.pinEdges(to: self, insets: UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 8))
        heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true

        isAccessibilityElement = true
        accessibilityLabel = title
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
        updateAppearance()
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override var isSelected: Bool {
        didSet { updateAppearance() }
    }

    @objc private func tapped() {
        isSelected.toggle()
        sendActions(for: .valueChanged)
    }

    private func updateAppearance() {
        backgroundColor = isSelected ? Theme.selectedFill : .white
        layer.borderColor = (isSelected ? Theme.accent : Theme.border).cgColor
        box.backgroundColor = isSelected ? Theme.accent : .clear
        box.layer.borderColor = (isSelected ? Theme.accent : UIColor(white: 0.8, alpha: 1)).cgColor
        checkmark.isHidden = !isSelected
        titleLabel.font = .systemFont(ofSize: 14, weight: isSelected ? .medium : .regular)
        titleLabel.textColor = isSelected ? Theme.textPrimary : Theme.textSecondary
        accessibilityTraits = isSelected ? [.button, .selected] : .button
    }
}
