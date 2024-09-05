// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class ContactUpdateTableViewController: UITableViewController {

    private enum Section: Int, CaseIterable {
        case firstname
        case lastname
        case avatar

        var title: String {
            switch self {
                case .firstname:
                    Strings.ContactUpdate.nameSectionTitle
                case .lastname:
                    Strings.ContactUpdate.lastnameSectionTitle
                case .avatar:
                    Strings.ContactUpdate.imageSectionTitle
            }
        }
    }

    private var contact: Contact
    private let store: ContactsStore

    var onDismiss: ((Contact) -> Void)?

    init(contact: Contact, store: ContactsStore) {
        self.contact = contact
        self.store = store
        super.init(style: .insetGrouped)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.ContactUpdate.title
        setupTableView()
    }

    private func setupTableView() {
        tableView.registerReusableCell(TextFieldTableViewCell.self)
        let footer = ButtonTableFooter(frame: .init(x: 0, y: 0, width: 150, height: 50))
        footer.buttonTitle = Strings.ContactUpdate.confirm
        footer.buttonAction = { [weak self] in
            guard let self = self else { return }

            self.saveChanges()
            self.onDismiss?(self.contact)
            self.dismiss(animated: true, completion: nil)
        }

        tableView.tableFooterView = footer
    }

    private func saveChanges() {
        store.update(contact: contact)
    }

    // MARK: - Data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        Section.allCases.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        Section(rawValue: section)?.title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = Section(rawValue: indexPath.section) else { fatalError("Unknown section") }

        let cell: TextFieldTableViewCell = tableView.dequeueReusableCell(for: indexPath)
        cell.selectionStyle = .none
        cell.tintColor = Theme.Color.secondary

        switch section {
            case .firstname:
                cell.text = contact.firstName
                cell.onTextChanged = { [weak self] text in
                    self?.contact.firstName = text
                }
            case .lastname:
                cell.text = contact.lastName
                cell.onTextChanged = { [weak self] text in
                    self?.contact.lastName = text
                }
            case .avatar:
                cell.text = contact.profileImageURL?.absoluteString
                cell.onTextChanged = { [weak self] text in
                    self?.contact.profileImageURL = text.map({ .init(string: $0) }) ?? nil
                }
        }

        return cell
    }
}
