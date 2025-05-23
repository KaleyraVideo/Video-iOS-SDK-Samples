// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit
import Combine
import KaleyraVideoSDK

final class ContactsViewController: UITableViewController, UISearchBarDelegate {

    enum Action: Equatable {
        case startCall(type: KaleyraVideoSDK.CallOptions.CallType?, callees: [String])
        case openChat(user: String)
    }

    private let appSettings: AppSettings
    private let viewModel: ContactsViewModel
    private let services: ServicesFactory

    private var selectedContacts: [String] = [] {
        didSet {
            if selectedContacts.count > 1 {
                groupCallButton.isEnabled = true
            } else {
                groupCallButton.isEnabled = false
            }
        }
    }

    private var dataSet: IndexedSections<String, Contact> = .init(sections: []) {
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
        controller.searchBar.placeholder = Strings.Contacts.searchPlaceholder
        controller.searchBar.delegate = self
        return controller
    }()

    private lazy var groupCallButton: UIBarButtonItem = {
        let button = UIBarButtonItem(image: Icons.phone, style: .plain, target: self, action: #selector(groupCallButtonTouched(sender:)))
        button.isEnabled = false
        return button
    }()

    private lazy var callSettingsButton: UIBarButtonItem = .init(image: Icons.callSettings,
                                                                 style: .plain,
                                                                 target: self,
                                                                 action: #selector(callSettingsButtonTouched(sender:)))

    private lazy var subscriptions = Set<AnyCancellable>()

    var onActionSelected: ((Action) -> Void)?
    var onContactProfileSelected: ((Contact) -> Void)?
    var onCallSettingsSelected: (() -> Void)?

    init(appSettings: AppSettings, viewModel: ContactsViewModel, services: ServicesFactory) {
        self.appSettings = appSettings
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

        title = Strings.Contacts.title
        setupTableView()
        setupNavigationItem()
        appSettings.$callSettings.sink { [weak self] settings in
            if settings.isGroup {
                self?.enableMultipleSelection(animated: true)
            } else {
                self?.disableMultipleSelection(animated: true)
            }
        }.store(in: &subscriptions)
        viewModel.$state.sink { [weak self] state in
            self?.display(state)
        }.store(in: &subscriptions)
        viewModel.load()
    }

    private func setupTableView() {
        tableView.rowHeight = 90
        tableView.keyboardDismissMode = .onDrag
        tableView.sectionIndexColor = Theme.Color.secondary
        tableView.tintColor = Theme.Color.secondary
        tableView.registerReusableCell(ContactTableViewCell.self)
        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:))))
    }

    private func setupNavigationItem() {
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        setupRightBarButtonItems()
    }

    private func setupRightBarButtonItems() {
        navigationItem.rightBarButtonItems = tableView.allowsMultipleSelection ? [callSettingsButton, groupCallButton] : [callSettingsButton]
    }

    private func display(_ state: ContactsViewModel.State) {
        switch state {
            case .initial:
                tableView.backgroundView = NoContentView.empty
            case .loading:
                tableView.backgroundView = NoContentView.loading
            case .error(let message):
                tableView.backgroundView = NoContentView.error(message: message, action: { [weak self] in self?.viewModel.load() })
            case .loaded(let contacts):
                if contacts.isEmpty {
                    tableView.backgroundView = NoContentView.empty
                    tableView.separatorColor = .clear
                    self.contacts = []
                } else {
                    tableView.backgroundView = nil
                    tableView.separatorColor = .gray
                    self.contacts = contacts
                }
        }
    }

    // MARK: - Enable / Disable multiple selection

    private func enableMultipleSelection(animated: Bool) {
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: animated)
        setupRightBarButtonItems()
    }

    private func disableMultipleSelection(animated: Bool) {
        tableView.allowsMultipleSelection = false
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.setEditing(false, animated: animated)

        selectedContacts.removeAll()
        setupRightBarButtonItems()
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

            if tableView.allowsMultipleSelection,
               let alias = cell.contact?.alias,
               selectedContacts.contains(alias) {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else {
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }

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

    // MARK: - TableViewDelegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !tableView.allowsMultipleSelection else {
            addContactToSelection(indexPath)
            return
        }

        guard let contact = dataSet.row(at: indexPath) else { return }

        searchController.searchBar.resignFirstResponder()
        onActionSelected?(.startCall(type: nil, callees: [contact.alias]))
    }

    override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        guard tableView.allowsMultipleSelection else { return indexPath }

        removeContactFromSelection(indexPath)

        return indexPath
    }

    private func addContactToSelection(_ indexPath: IndexPath) {
        guard let contact = dataSet.row(at: indexPath),
              selectedContacts.lastIndex(of: contact.alias) == nil else { return }

        selectedContacts.append(contact.alias)
    }

    private func removeContactFromSelection(_ indexPath: IndexPath) {
        guard let contact = dataSet.row(at: indexPath),
              let index = selectedContacts.lastIndex(of: contact.alias) else { return }

        selectedContacts.remove(at: index)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let contact = dataSet.row(at: indexPath) else { return nil }

        let callAction = UIContextualAction.call { [weak self] in
            self?.onActionSelected?(.startCall(type: .audioOnly, callees: [contact.alias]))
        }

        let videoCallAction = UIContextualAction.video { [weak self] in
            self?.onActionSelected?(.startCall(type: .audioVideo, callees: [contact.alias]))
        }

        let chatAction = UIContextualAction.chat { [weak self] in
            self?.onActionSelected?(.openChat(user: contact.alias))
        }

        return .init(actions: [callAction, videoCallAction, chatAction])
    }

    // MARK: - Search delegate

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        viewModel.filter(searchFilter: searchText)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        viewModel.filter(searchFilter: "")
    }

    // MARK: - Actions

    @objc
    private func longPress(sender: UILongPressGestureRecognizer) {
        guard let indexPath = tableView.indexPathForRow(at: sender.location(in: tableView)),
              let cell = tableView.cellForRow(at: indexPath) as? ContactTableViewCell,
              let contact = cell.contact else { return }

        onContactProfileSelected?(contact)
    }

    @objc
    private func groupCallButtonTouched(sender: UIBarButtonItem) {
        guard selectedContacts.count > 1 else { return }

        onActionSelected?(.startCall(type: nil, callees: selectedContacts))
    }

    @objc
    private func callSettingsButtonTouched(sender: UIBarButtonItem) {
        onCallSettingsSelected?()
    }
}

private extension UIContextualAction {

    static func call(handler: @escaping () -> Void) -> UIContextualAction {
        .init(title: Strings.Contacts.Actions.call, image: Icons.phone, handler: handler)
    }

    static func video(handler: @escaping () -> Void) -> UIContextualAction  {
        .init(title: Strings.Contacts.Actions.video, image: Icons.videoCallAction, handler: handler)
    }

    static func chat(handler: @escaping () -> Void) -> UIContextualAction {
        .init(title: Strings.Contacts.Actions.chat, image: Icons.chatAction, handler: handler)
    }

    convenience init(title: String, image: UIImage?, handler: @escaping () -> Void) {
        self.init(style: .normal, title: title, handler: { _, _, completion in
            handler()
            completion(true)
        })

        self.image = image
        self.backgroundColor = Theme.Color.primary
    }
}

private extension NoContentView {

    static var empty: NoContentView = .init(style: .titleAndSubtitle(title: Strings.Contacts.NoContent.title,
                                                                     subtitle: Strings.Contacts.NoContent.subtitle),
                                            header: LoaderView(image: Icons.logo256))

    static func error(message: String, action: @escaping () -> Void) -> NoContentView {
        .init(style: .action(title: Strings.Contacts.Alert.title,
                             subtitle: message,
                             actionTitle: Strings.Contacts.Alert.retryAction,
                             action: action),
              header: LoaderView(image: Icons.logo256))
    }

    static var loading: NoContentView {
        let loader = LoaderView(image: Icons.logo256)
        loader.startAnimating(with: 1)
        return .init(style: .message(text: Strings.Contacts.Loading.title), header: loader)
    }
}
