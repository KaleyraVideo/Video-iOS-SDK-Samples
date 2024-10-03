// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class TextFieldTableViewCell: UITableViewCell {

    var text: String? {
        get {
            textField.text
        }

        set {
            textField.text = newValue
        }
    }

    var placeholder: String? {
        get {
            textField.placeholder
        }

        set {
            textField.placeholder = newValue
        }
    }

    var onTextChanged: ((String?) -> Void)?

    // MARK: - Field

    private lazy var textField: UITextField = {
        let field = UITextField()
        field.translatesAutoresizingMaskIntoConstraints = false
        field.inputAccessoryView = UIToolbar.createWithRightAlignedDismissButton(title: Strings.Generic.confirm,
                                                                                 target: self,
                                                                                 action: #selector(onDoneButtonTouched(_:)))
        field.addTarget(self, action: #selector(onTextEditingChanged(_:)), for: .editingChanged)
        field.addTarget(self, action: #selector(onTextEditingEnded(_:)), for: .editingDidEnd)
        return field
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    private func setup() {
        tintColor = Theme.Color.secondary
        selectionStyle = .none
        contentView.addSubview(textField)
        NSLayoutConstraint.activate([
            textField.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            textField.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            textField.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            textField.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }

    // MARK: - Actions

    @objc
    private func onTextEditingChanged(_ sender: UITextField) {
        onTextChanged?(text)
    }

    @objc
    private func onTextEditingEnded(_ sender: UITextField) {
        onTextChanged?(text)
    }

    @objc
    private func onDoneButtonTouched(_ sender: UIBarButtonItem) {
        textField.resignFirstResponder()
    }

    // MARK: - Reuse

    override func prepareForReuse() {
        super.prepareForReuse()

        onTextChanged = nil
        text = nil
    }
}
