// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class ContactProfileViewController: UITableViewController {

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
    private let book: AddressBook

    var onDismiss: ((Contact) -> Void)?

    init(contact: Contact, book: AddressBook) {
        self.contact = contact
        self.book = book
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
        tableView.tableFooterView = ButtonTableFooter(title: Strings.ContactUpdate.confirm) { [weak self] in
            guard let self = self else { return }

            self.saveChanges()
            self.onDismiss?(self.contact)
            self.dismiss(animated: true)
        }
    }

    private func saveChanges() {
        book.update(contact: contact)
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
                cell.text = contact.imageURL?.absoluteString
                cell.onTextChanged = { [weak self] text in
                    self?.contact.imageURL = text.map({ .init(string: $0) }) ?? nil
                }
        }

        return cell
    }
}
