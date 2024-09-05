// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

final class LoginViewController: UITableViewController {

    private let services: ServicesFactory
    var onReady: (() -> Void)?
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

        title = Strings.Login.title
        setupTableView()
        onReady?()
#if SAMPLE_CUSTOMIZABLE_THEME
        themeChanged(theme: services.makeThemeStorage().getSelectedTheme())
#endif
    }

    private func setupTableView() {
        tableView.registerReusableCell(UserCell.self)
        tableView.keyboardDismissMode = .onDrag
        tableView.rowHeight = 90
        tableView.sectionIndexColor = Theme.Color.secondary
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
}
#if SAMPLE_CUSTOMIZABLE_THEME
extension LoginViewController: Themable {

    func themeChanged(theme: AppTheme) {
        view.backgroundColor = theme.primaryBackgroundColor.toUIColor()
        tableView.backgroundColor = theme.secondaryBackgroundColor.toUIColor()
        tableViewFont = theme.font?.toUIFont() ?? UIFont.systemFont(ofSize: 20)
        tableViewAccessoryFont = theme.secondaryFont?.toUIFont() ?? UIFont.systemFont(ofSize: 18)
        view.subviews.forEach { subview in
            subview.tintColor = theme.accentColor.toUIColor()
        }
        tableView.reloadData()
    }
}
#endif

extension LoginViewController: ContactsPresenterOutput {

    func display(_ state: ContactsViewModel.State) {
        switch state {
            case .initial:
                tableView.backgroundView = NoContentView.empty
            case .loading:
                tableView.backgroundView = NoContentView.loading
            case .error(let message):
                tableView.backgroundView = NoContentView.error(message: message, action: { [weak self] in self?.onReady?() })

                guard let handleErrorTapped = handleErrorTapped else { return }

                showAlertMessageWithAction(title: Strings.Login.ErrorAlert.title,
                                           message: message,
                                           buttonTitle: Strings.Login.ErrorAlert.cancelAction,
                                           buttonActionTitle: Strings.Login.ErrorAlert.exitAction,
                                           buttonActionHandler: handleErrorTapped)
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

    static var empty: NoContentView = .init(style: .titleAndSubtitle(title: Strings.Login.emptyTitle,
                                                                     subtitle: Strings.Login.emptySubtitle),
                                            header: LoaderView(image: Icons.logo256))

    static func error(message: String, action: @escaping () -> Void) -> NoContentView {
        .init(style: .action(title: Strings.Login.ErrorAlert.title,
                             subtitle: message,
                             actionTitle: Strings.Login.ErrorAlert.retryAction,
                             action: action),
              header: LoaderView(image: Icons.logo256))
    }

    static var loading: NoContentView {
        let loader = LoaderView(image: Icons.logo256)
        loader.startAnimating(with: 1)
        return .init(style: .message(text: Strings.Login.loadingTitle), header: loader)
    }
}
