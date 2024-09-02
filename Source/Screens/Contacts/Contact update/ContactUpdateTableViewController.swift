// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class ContactUpdateTableViewController: UITableViewController {

    private var contact: Contact
    private let services: ServicesFactory
    private var tableViewDataSource = [String: [String]]()
    private var textfieldFirstName = UITextField()
    private var textfieldLastName = UITextField()
    private var textfieldProfileUrl = UITextField()

    var onDismiss: ((Contact) -> Void)?

    init(contact: Contact, services: ServicesFactory) {
        self.contact = contact
        self.services = services
        super.init(style: .insetGrouped)
        initialSetup()
    }

    private func initialSetup() {
        tableViewDataSource[Strings.ContactUpdate.nameSectionTitle] = [
            contact.firstName ?? ""
        ]

        tableViewDataSource[Strings.ContactUpdate.lastnameSectionTitle] = [
            contact.lastName ?? ""
        ]

        tableViewDataSource[Strings.ContactUpdate.imageSectionTitle] = [
            contact.profileImageURL?.absoluteString ?? ""
        ]
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = Strings.ContactUpdate.title
        setupTextFields()
        setupSubViews()
        insertTableViewFooter()
    }

    private func setupTextFields() {
        textfieldLastName.addTarget(self, action: #selector(onEditingChanged(sender:)), for: .editingChanged)
        textfieldFirstName.addTarget(self, action: #selector(onEditingChanged(sender:)), for: .editingChanged)
        textfieldProfileUrl.addTarget(self, action: #selector(onEditingChanged(sender:)), for: .editingChanged)
    }

    private func setupSubViews() {
        tableView.registerReusableCell(UITableViewCell.self)

        textfieldLastName.delegate = self
        textfieldLastName.inputAccessoryView = createToolbar()

        textfieldFirstName.delegate = self
        textfieldFirstName.inputAccessoryView = createToolbar()

        textfieldProfileUrl.delegate = self
        textfieldProfileUrl.inputAccessoryView = createToolbar()
    }

    private func insertTableViewFooter() {
        let footer = ButtonTableFooter(frame: .init(x: 0, y: 0, width: 150, height: 50))
        footer.buttonTitle = Strings.ContactUpdate.confirm
        footer.buttonAction = { [weak self] in
            guard let self = self else { return }

            self.onDismiss?(self.contact)
            self.dismiss(animated: true, completion: nil)
        }

        tableView.tableFooterView = footer
    }

    private func getSectionKey(from index: Int) -> String {
        switch index {
            case 0:
                return Strings.ContactUpdate.nameSectionTitle
            case 1:
                return Strings.ContactUpdate.lastnameSectionTitle
            default:
                return Strings.ContactUpdate.imageSectionTitle
        }
    }

    private func createToolbar() -> UIToolbar {
        UIToolbar.createWithRightAlignedDismissButton(title: Strings.Generic.confirm, target: self, action: #selector(onDoneTapped))
    }

    @objc
    private func onDoneTapped() {
        textfieldFirstName.resignFirstResponder()
        textfieldLastName.resignFirstResponder()
        textfieldProfileUrl.resignFirstResponder()
    }

    @objc
    private func onEditingChanged(sender: UITextField) {
        switch sender {
        case textfieldFirstName:
            contact.firstName = sender.text ?? ""
        case textfieldProfileUrl:
            guard let profileUrl = sender.text, let url = URL(string: profileUrl) else { return }
            contact.profileImageURL = url
        default:
            contact.lastName = sender.text ?? ""
        }
    }
}

// MARK: - Table view data source
extension ContactUpdateTableViewController {

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionKey = getSectionKey(from: section)
        return tableViewDataSource[sectionKey]?.count ?? 0
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Array(tableViewDataSource.keys).count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return getSectionKey(from: section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath)

        let sectionKey = getSectionKey(from: indexPath.section)
        cell.selectionStyle = .none
        cell.tintColor = Theme.Color.secondary

        switch sectionKey {
            case Strings.ContactUpdate.nameSectionTitle:
                textfieldFirstName.frame = CGRect(x: 20, y: 0, width: cell.contentView.frame.width, height: 42)
                textfieldFirstName.text = tableViewDataSource[sectionKey]?[indexPath.row]
                cell.contentView.addSubview(textfieldFirstName)
            case Strings.ContactUpdate.lastnameSectionTitle:
                textfieldLastName.frame = CGRect(x: 20, y: 0, width: cell.contentView.frame.width, height: 42)
                textfieldLastName.text = tableViewDataSource[sectionKey]?[indexPath.row]
                cell.contentView.addSubview(textfieldLastName)
            default:
                textfieldProfileUrl.frame = CGRect(x: 20, y: 0, width: cell.contentView.frame.width, height: 42)
                textfieldProfileUrl.text = tableViewDataSource[sectionKey]?[indexPath.row]
                cell.contentView.addSubview(textfieldProfileUrl)
        }

        return cell
    }
}

extension ContactUpdateTableViewController: UITextFieldDelegate {

    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        switch textField {
            case textfieldFirstName:
                contact.firstName = textField.text ?? ""
            case textfieldProfileUrl:
                guard let profileUrl = textField.text, let url = URL(string: profileUrl) else { return }
                contact.profileImageURL = url
            default:
                contact.lastName = textField.text ?? ""
        }
    }
}

