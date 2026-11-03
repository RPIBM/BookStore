import UIKit

final class CatalogViewController: UIViewController {

    private enum Section {
        case featured
        case books
    }

    private let container: AppContainer
    private let viewModel: CatalogViewModel
    private let searchController = UISearchController(searchResultsController: nil)
    private let emptyLabel = UILabel()
    private var sections: [Section] = []

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: makeLayout())
        view.backgroundColor = .white
        view.dataSource = self
        view.delegate = self
        view.keyboardDismissMode = .onDrag
        view.register(BookCell.self, forCellWithReuseIdentifier: BookCell.reuseIdentifier)
        view.register(FeaturedBooksCell.self, forCellWithReuseIdentifier: FeaturedBooksCell.reuseIdentifier)
        view.register(
            SectionHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: SectionHeaderView.reuseIdentifier)
        return view
    }()

    init(container: AppContainer) {
        self.container = container
        viewModel = CatalogViewModel(repository: container.repository)
        super.init(nibName: nil, bundle: nil)
        title = "Bookstore"
        tabBarItem = UITabBarItem(title: "Browse", image: UIImage(systemName: "books.vertical"), tag: 0)
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        navigationItem.largeTitleDisplayMode = .always
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "line.3.horizontal.decrease.circle"),
            style: .plain, target: self, action: #selector(filterTapped))
        navigationItem.rightBarButtonItem?.accessibilityLabel = "Sort and filter"

        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search title, author or genre"
        // The navigation bar is navy, so give the field a light background to keep the placeholder readable.
        searchController.searchBar.searchTextField.backgroundColor = .white
        searchController.searchBar.searchTextField.textColor = Theme.textPrimary
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        view.addSubview(collectionView)
        collectionView.pinEdges(to: view)

        emptyLabel.text = "No books match your search.\nTry changing your filters."
        emptyLabel.numberOfLines = 0
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = Theme.textSecondary
        emptyLabel.font = .systemFont(ofSize: 15)
        emptyLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(emptyLabel)
        NSLayoutConstraint.activate([
            emptyLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            emptyLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            emptyLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            emptyLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -32)
        ])

        viewModel.onChange = { [weak self] in self?.reload() }
        reload()
    }

    private func reload() {
        sections = viewModel.showsFeaturedSection ? [.featured, .books] : [.books]
        emptyLabel.isHidden = !viewModel.books.isEmpty
        updateFilterBadge()
        collectionView.reloadData()
    }

    private func updateFilterBadge() {
        let count = viewModel.query.activeFilterCount
        navigationItem.rightBarButtonItem?.image = UIImage(
            systemName: viewModel.query.hasCustomSortOrFilter
                ? "line.3.horizontal.decrease.circle.fill"
                : "line.3.horizontal.decrease.circle")
        navigationItem.rightBarButtonItem?.accessibilityValue = count > 0 ? "\(count) filters active" : nil
    }

    private func makeLayout() -> UICollectionViewLayout {
        UICollectionViewCompositionalLayout { [weak self] index, environment in
            guard let self, self.sections.indices.contains(index) else { return nil }
            switch self.sections[index] {
            case .featured:
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .absolute(206)),
                    subitems: [item])
                return NSCollectionLayoutSection(group: group)

            case .books:
                let columns = environment.container.effectiveContentSize.width > 600 ? 4 : 2
                let item = NSCollectionLayoutItem(layoutSize: .init(
                    widthDimension: .fractionalWidth(1.0 / CGFloat(columns)),
                    heightDimension: .estimated(300)))
                item.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 8)
                let group = NSCollectionLayoutGroup.horizontal(
                    layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(300)),
                    repeatingSubitem: item, count: columns)
                let section = NSCollectionLayoutSection(group: group)
                section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 8, bottom: 16, trailing: 8)
                let header = NSCollectionLayoutBoundarySupplementaryItem(
                    layoutSize: .init(widthDimension: .fractionalWidth(1), heightDimension: .estimated(40)),
                    elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
                section.boundarySupplementaryItems = [header]
                return section
            }
        }
    }

    private func showDetail(for book: Book) {
        let detail = BookDetailViewController(book: book, cart: container.cart)
        navigationController?.pushViewController(detail, animated: true)
    }

    @objc private func filterTapped() {
        let controller = SortFilterViewController(query: viewModel.query)
        controller.onApply = { [weak self] query in
            guard let self else { return }
            var updated = query
            updated.searchText = self.viewModel.query.searchText
            self.viewModel.query = updated
        }
        let navigation = UINavigationController(rootViewController: controller)
        let appearance = Theme.styleNavigationBar()
        navigation.navigationBar.standardAppearance = appearance
        navigation.navigationBar.scrollEdgeAppearance = appearance
        navigation.navigationBar.tintColor = .white
        navigation.modalPresentationStyle = .pageSheet
        present(navigation, animated: true)
    }
}

// MARK: - UICollectionViewDataSource / Delegate

extension CatalogViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .featured: return 1
        case .books: return viewModel.books.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case .featured:
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: FeaturedBooksCell.reuseIdentifier, for: indexPath)
            if let featured = cell as? FeaturedBooksCell {
                featured.configure(with: viewModel.featuredBestsellers)
                featured.onSelect = { [weak self] book in self?.showDetail(for: book) }
            }
            return cell
        case .books:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: BookCell.reuseIdentifier, for: indexPath)
            (cell as? BookCell)?.configure(with: viewModel.books[indexPath.item])
            return cell
        }
    }

    func collectionView(
        _ collectionView: UICollectionView,
        viewForSupplementaryElementOfKind kind: String,
        at indexPath: IndexPath
    ) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: SectionHeaderView.reuseIdentifier, for: indexPath)
        (header as? SectionHeaderView)?.label.text = viewModel.resultsTitle
        return header
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard sections[indexPath.section] == .books else { return }
        showDetail(for: viewModel.books[indexPath.item])
    }
}

// MARK: - UISearchResultsUpdating

extension CatalogViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        viewModel.query.searchText = searchController.searchBar.text ?? ""
    }
}
