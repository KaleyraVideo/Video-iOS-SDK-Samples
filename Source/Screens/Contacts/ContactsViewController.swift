// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import UIKit
import KaleyraVideoSDK

final class ContactsViewController: UITableViewController {

    enum Action {
        case startCall(type: KaleyraVideoSDK.CallOptions.CallType?, callees: [String])
        case openChat(user: String)
    }

    private let services: ServicesFactory

    var onReady: (() -> Void)?
    var onAction: ((Action) -> Void)?
    var onUpdateSelectedContacts: (([String]) -> Void)?
    var onUpdateContact: ((Contact) -> Void)?

    private var selectedContactsAlias: [String] = [] {
        didSet {
            onUpdateSelectedContacts?(selectedContactsAlias)
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

    init(services: ServicesFactory) {
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
#if SAMPLE_CUSTOMIZABLE_THEME
        themeChanged(theme: services.makeThemeStorage().getSelectedTheme())
#endif
        onReady?()
    }

    private func setupTableView() {
        tableView.rowHeight = 90
        tableView.keyboardDismissMode = .onDrag
        tableView.sectionIndexColor = Theme.Color.secondary
        tableView.tintColor = Theme.Color.secondary
        tableView.registerReusableCell(UserCell.self)
        tableView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(longPress(sender:))))
    }

    // MARK: - Enable / Disable multiple selection

    func enableMultipleSelection(_ animated: Bool) {
        tableView.allowsMultipleSelection = true
        tableView.allowsMultipleSelectionDuringEditing = true
        tableView.setEditing(true, animated: animated)
    }

    func disableMultipleSelection(_ animated: Bool) {
        tableView.allowsMultipleSelection = false
        tableView.allowsMultipleSelectionDuringEditing = false
        tableView.setEditing(false, animated: animated)

        selectedContactsAlias.removeAll()
    }

    // MARK: - LongPress handler

    @objc(longPress:)
    func longPress(sender: UILongPressGestureRecognizer) {
        guard let indexPath = tableView.indexPathForRow(at: sender.location(in: tableView)),
                let cell = tableView.cellForRow(at: indexPath) as? UserCell,
                let contact = cell.contact else { return }

        onUpdateContact?(contact)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        dataSet.numberOfSections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        dataSet.numberOfRowsIn(section: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UserCell = tableView.dequeueReusableCell(for: indexPath)

        if let contact = dataSet.row(at: indexPath) {
            cell.contact = contact

            if tableView.allowsMultipleSelection,
               let alias = cell.contact?.alias,
               selectedContactsAlias.contains(alias) {
                tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else {
                tableView.deselectRow(at: indexPath, animated: false)
            }
        }

#if SAMPLE_CUSTOMIZABLE_THEME
        cell.themeChanged(theme: themeStorage.getSelectedTheme())
#endif

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

        onAction?(.startCall(type: nil, callees: [contact.alias]))
    }

    override func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        guard tableView.allowsMultipleSelection else { return indexPath }

        removeContactFromSelection(indexPath)

        return indexPath
    }

    private func addContactToSelection(_ indexPath: IndexPath) {
        guard let contact = dataSet.row(at: indexPath),
              selectedContactsAlias.lastIndex(of: contact.alias) == nil else { return }

        selectedContactsAlias.append(contact.alias)
    }

    private func removeContactFromSelection(_ indexPath: IndexPath) {
        guard let contact = dataSet.row(at: indexPath),
              let index = selectedContactsAlias.lastIndex(of: contact.alias) else { return }

        selectedContactsAlias.remove(at: index)
    }

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let contact = dataSet.row(at: indexPath) else { return nil }

        let callAction = UIContextualAction(title: Strings.Contacts.Actions.call,
                                            image: Icons.phone,
                                            controller: self,
                                            action: .startCall(type: .audioOnly, callees: [contact.alias]))

        let videoCallAction = UIContextualAction(title: Strings.Contacts.Actions.video,
                                                 image: Icons.videoCallAction,
                                                 controller: self,
                                                 action: .startCall(type: .audioVideo, callees: [contact.alias]))

        let chatAction = UIContextualAction(title: Strings.Contacts.Actions.chat,
                                            image: Icons.chatAction,
                                            controller: self,
                                            action: .openChat(user: contact.alias))

        return .init(actions: [callAction, videoCallAction, chatAction])
    }
}

private extension UIContextualAction {

    convenience init(title: String, image: UIImage?, controller: ContactsViewController, action: ContactsViewController.Action) {
        self.init(style: .normal, title: title, handler: { [weak controller] _, _, completion in
            controller?.onAction?(action)
            completion(true)
        })

        self.image = image

#if SAMPLE_CUSTOMIZABLE_THEME
        self.backgroundColor = themeStorage.getSelectedTheme().accentColor.toUIColor()
#else
        self.backgroundColor = Theme.Color.primary
#endif
    }
}

#if SAMPLE_CUSTOMIZABLE_THEME
extension ContactsViewController: Themable {

    func themeChanged(theme: AppTheme) {
        view.backgroundColor = theme.primaryBackgroundColor.toUIColor()
        tableView.backgroundColor = theme.secondaryBackgroundColor.toUIColor()
        tableView.sectionIndexColor = theme.accentColor.toUIColor()
        tableView.tintColor = theme.accentColor.toUIColor()
        tableView.reloadData()
    }
}
#endif

// MARK: - ContactsPresenterOutput

extension ContactsViewController: ContactsPresenterOutput {

    func display(_ state: ContactsViewModel.State) {
        switch state {
            case .initial:
                tableView.backgroundView = NoContentView.empty
            case .loading:
                tableView.backgroundView = NoContentView.loading
            case .error(let message):
                tableView.backgroundView = NoContentView.error(message: message, action: { [weak self] in self?.onReady?() })
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
}

private extension NoContentView {

    static var empty: NoContentView = .init(style: .titleAndSubtitle(title: Strings.Contacts.emptyTitle,
                                                                     subtitle: Strings.Contacts.emptySubtitle),
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
        return .init(style: .message(text: Strings.Contacts.loadingTitle), header: loader)
    }
}
