// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit
import Combine

final class LoginViewController: UITableViewController, UISearchBarDelegate {

    private let viewModel: ContactsViewModel
    private let services: ServicesFactory

    var onSelection: ((Contact) -> Void)?
    var handleErrorTapped: (() -> Void)?

    private var dataSet: IndexedSections<String, Contact> = .init() {
        didSet {
            tableView.reloadData()
        }
    }

    private var contacts: [Contact] {
        get {
            dataSet.allRows
        }
        set {
            dataSet = .init(contacts: newValue)
        }
    }

    private lazy var searchController: UISearchController = {
        let controller = UISearchController(searchResultsController: nil)
        controller.obscuresBackgroundDuringPresentation = false
        controller.searchBar.placeholder = Strings.Login.searchPlaceholder
        controller.searchBar.delegate = self
        controller.searchBar.searchBarStyle = .default
        return controller
    }()

    private lazy var subscriptions = Set<AnyCancellable>()

    init(viewModel: ContactsViewModel, services: ServicesFactory) {
        self.viewModel = viewModel
        self.services = services
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("Not available")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.Login.title
        setupNavigationItem()
        setupTableView()
        viewModel.$state.sink { [weak self] state in
            self?.display(state)
        }.store(in: &subscriptions)
        viewModel.load()
    }

    private func setupNavigationItem() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }

    private func setupTableView() {
        tableView.registerReusableCell(ContactTableViewCell.self)
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 90
        tableView.sectionIndexColor = Theme.Color.secondary
    }

    private func display(_ state: ContactsViewModel.State) {
        switch state {
            case .initial:
                tableView.backgroundView = NoContentView.empty
            case .loading:
                tableView.backgroundView = NoContentView.loading
            case .error(let message):
                tableView.backgroundView = NoContentView.error(message: message, action: { [weak self] in
                    self?.viewModel.load()
                })

                guard let handleErrorTapped = handleErrorTapped else { return }

                presentAlert(.errorAlert(message: message, exitAction: handleErrorTapped))
            case .loaded(let contacts):
                if contacts.isEmpty {
                    tableView.backgroundView = NoContentView.empty
                    tableView.separatorColor = .clear
                    self.contacts = []
                } else {
                    tableView.isHidden = false
                    tableView.backgroundView = nil
                    tableView.separatorColor = .gray
                    self.contacts = contacts
                }
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        dataSet.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSet.numberOfRowsIn(section: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: ContactTableViewCell = tableView.dequeueReusableCell(for: indexPath)

        if let contact = dataSet.row(at: indexPath) {
            cell.contact = contact
        }

        cell.selectionStyle = .none

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        dataSet.indexFor(section: section)
    }

    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        dataSet.sectionForSectionIndex(title: title, index: index)
    }

    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        dataSet.indexes
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let contact = dataSet.row(at: indexPath) else { return }

        onSelection?(contact)
    }

    // MARK: - Search bar delegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filter(searchFilter: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.filter(searchFilter: "")
    }
}

private extension NoContentView {

    static var empty: NoContentView = .init(style: .titleAndSubtitle(title: Strings.Login.NoContent.title,
                                                                     subtitle: Strings.Login.NoContent.subtitle),
                                            header: LoaderView(image: Icons.logo256))

    static func error(message: String, action: @escaping () -> Void) -> NoContentView {
        .init(style: .action(title: Strings.Login.Alert.title,
                             subtitle: message,
                             actionTitle: Strings.Login.Alert.retryAction,
                             action: action),
              header: LoaderView(image: Icons.logo256))
    }

    static var loading: NoContentView {
        let loader = LoaderView(image: Icons.logo256)
        loader.startAnimating(with: 1)
        return .init(style: .message(text: Strings.Login.Loading.title), header: loader)
    }
}

private extension UIAlertController {

    static func errorAlert(message: String, exitAction: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController.alert(title: Strings.Login.Alert.title, message: message)
        alert.addAction(.cancel(title: Strings.Login.Alert.cancelAction))
        alert.addAction(.destructive(title: Strings.Login.Alert.exitAction, handler: exitAction))
        return alert
    }
}
