import UIKit

/// "Sort & Filter" screen, modelled on the supplied design (without a price-range slider).
/// The two toggle rows can be shown or hidden with `showsBestsellersToggle` / `showsHighlyRatedToggle`.
final class SortFilterViewController: UIViewController {

    var onApply: ((BookQuery) -> Void)?

    var showsBestsellersToggle = true {
        didSet { bestsellersRow.isHidden = !showsBestsellersToggle }
    }

    var showsHighlyRatedToggle = true {
        didSet { highlyRatedRow.isHidden = !showsHighlyRatedToggle }
    }

    private var draft: BookQuery
    private var sortRows: [(option: SortOption, row: SortOptionRow)] = []
    private var genreChips: [(genre: Genre, chip: CheckboxChip)] = []
    private var priceChips: [(band: PriceBand, chip: CheckboxChip)] = []

    private let bestsellersRow = FilterToggleRow(
        title: "Bestsellers", subtitle: "Most-loved titles right now", showsPopularBadge: true)
    private let highlyRatedRow = FilterToggleRow(
        title: "Highly rated", subtitle: "Books rated 4.5 stars and above", showsPopularBadge: true)

    init(query: BookQuery) {
        draft = query
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Sort & Filter"
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close, target: self, action: #selector(closeTapped))

        buildLayout()
        bestsellersRow.isHidden = !showsBestsellersToggle
        highlyRatedRow.isHidden = !showsHighlyRatedToggle
        syncControls()
    }

    // MARK: - Layout

    private func buildLayout() {
        let scrollView = UIScrollView()
        scrollView.alwaysBounceVertical = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        let bottomBar = makeBottomBar()
        bottomBar.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(scrollView)
        view.addSubview(bottomBar)

        let content = UIStackView(arrangedSubviews: makeSections())
        content.axis = .vertical
        content.isLayoutMarginsRelativeArrangement = true
        content.layoutMargins = UIEdgeInsets(top: 8, left: 16, bottom: 24, right: 16)
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
    }

    private func makeSections() -> [UIView] {
        var views: [UIView] = []

        // Sort by
        views.append(sectionTitle("Sort by"))
        let options = SortOption.allCases
        for (index, option) in options.enumerated() {
            let row = SortOptionRow(title: option.title, subtitle: option.subtitle)
            row.addTarget(self, action: #selector(sortRowTapped(_:)), for: .touchUpInside)
            sortRows.append((option, row))
            views.append(row)
            if index < options.count - 1 { views.append(divider()) }
        }
        views.append(sectionBreak())

        // Filter by
        views.append(sectionTitle("Filter by"))
        bestsellersRow.onChange = { [weak self] isOn in self?.draft.bestsellersOnly = isOn }
        highlyRatedRow.onChange = { [weak self] isOn in self?.draft.highlyRatedOnly = isOn }
        views.append(bestsellersRow)
        views.append(highlyRatedRow)
        views.append(sectionBreak())

        // Genre
        views.append(sectionTitle("Genre"))
        genreChips = Genre.allCases.map { genre in
            let chip = CheckboxChip(title: genre.rawValue)
            chip.addTarget(self, action: #selector(genreChipChanged(_:)), for: .valueChanged)
            return (genre, chip)
        }
        views.append(makeGrid(genreChips.map { $0.chip }))
        views.append(sectionBreak())

        // Price
        views.append(sectionTitle("Price"))
        priceChips = PriceBand.allCases.map { band in
            let chip = CheckboxChip(title: band.title)
            chip.addTarget(self, action: #selector(priceChipChanged(_:)), for: .valueChanged)
            return (band, chip)
        }
        views.append(makeGrid(priceChips.map { $0.chip }))

        return views
    }

    private func makeBottomBar() -> UIView {
        let bar = UIView()
        bar.backgroundColor = .white

        let border = UIView()
        border.backgroundColor = Theme.border
        border.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(border)

        let showResults = UIButton(type: .system)
        showResults.setTitle("Show results", for: .normal)
        showResults.setTitleColor(.white, for: .normal)
        showResults.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        showResults.backgroundColor = Theme.accent
        showResults.layer.cornerRadius = 10
        showResults.addTarget(self, action: #selector(showResultsTapped), for: .touchUpInside)
        showResults.heightAnchor.constraint(equalToConstant: 48).isActive = true

        let clearAll = UIButton(type: .system)
        clearAll.setTitle("Clear All", for: .normal)
        clearAll.setTitleColor(Theme.accent, for: .normal)
        clearAll.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
        clearAll.addTarget(self, action: #selector(clearAllTapped), for: .touchUpInside)
        clearAll.heightAnchor.constraint(equalToConstant: 32).isActive = true

        let stack = UIStackView(arrangedSubviews: [showResults, clearAll])
        stack.axis = .vertical
        stack.spacing = 4
        stack.translatesAutoresizingMaskIntoConstraints = false
        bar.addSubview(stack)

        NSLayoutConstraint.activate([
            border.topAnchor.constraint(equalTo: bar.topAnchor),
            border.leadingAnchor.constraint(equalTo: bar.leadingAnchor),
            border.trailingAnchor.constraint(equalTo: bar.trailingAnchor),
            border.heightAnchor.constraint(equalToConstant: 1),

            stack.topAnchor.constraint(equalTo: bar.topAnchor, constant: 12),
            stack.leadingAnchor.constraint(equalTo: bar.leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: bar.trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bar.safeAreaLayoutGuide.bottomAnchor, constant: -8)
        ])
        return bar
    }

    private func sectionTitle(_ text: String) -> UIView {
        let label = UILabel()
        label.text = text
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = Theme.textPrimary
        label.accessibilityTraits = .header

        let container = UIView()
        container.addSubview(label)
        label.pinEdges(to: container, insets: UIEdgeInsets(top: 12, left: 0, bottom: 4, right: 0))
        return container
    }

    private func divider() -> UIView {
        let line = UIView()
        line.backgroundColor = Theme.border
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        return line
    }

    private func sectionBreak() -> UIView {
        let container = UIView()
        let line = UIView()
        line.backgroundColor = Theme.border
        line.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(line)
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 24),
            line.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            line.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            line.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            line.heightAnchor.constraint(equalToConstant: 1)
        ])
        return container
    }

    private func makeGrid(_ chips: [CheckboxChip]) -> UIView {
        let grid = UIStackView()
        grid.axis = .vertical
        grid.spacing = 8
        for start in stride(from: 0, to: chips.count, by: 2) {
            var rowViews: [UIView] = Array(chips[start..<min(start + 2, chips.count)])
            if rowViews.count == 1 { rowViews.append(UIView()) }
            let row = UIStackView(arrangedSubviews: rowViews)
            row.spacing = 8
            row.distribution = .fillEqually
            grid.addArrangedSubview(row)
        }
        return grid
    }

    // MARK: - State

    private func syncControls() {
        sortRows.forEach { $0.row.isSelected = ($0.option == draft.sort) }
        genreChips.forEach { $0.chip.isSelected = draft.genres.contains($0.genre) }
        priceChips.forEach { $0.chip.isSelected = draft.priceBands.contains($0.band) }
        bestsellersRow.isOn = draft.bestsellersOnly
        highlyRatedRow.isOn = draft.highlyRatedOnly
    }

    // MARK: - Actions

    @objc private func sortRowTapped(_ sender: SortOptionRow) {
        guard let match = sortRows.first(where: { $0.row === sender }) else { return }
        draft.sort = match.option
        syncControls()
    }

    @objc private func genreChipChanged(_ sender: CheckboxChip) {
        guard let match = genreChips.first(where: { $0.chip === sender }) else { return }
        if sender.isSelected { draft.genres.insert(match.genre) } else { draft.genres.remove(match.genre) }
    }

    @objc private func priceChipChanged(_ sender: CheckboxChip) {
        guard let match = priceChips.first(where: { $0.chip === sender }) else { return }
        if sender.isSelected { draft.priceBands.insert(match.band) } else { draft.priceBands.remove(match.band) }
    }

    @objc private func showResultsTapped() {
        onApply?(draft)
        dismiss(animated: true)
    }

    @objc private func clearAllTapped() {
        draft = BookQuery(searchText: draft.searchText)
        syncControls()
    }

    @objc private func closeTapped() {
        dismiss(animated: true)
    }
}
