// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class SwitchTableViewCell: UITableViewCell {

    var `switch`: UISwitch? {
        accessoryView as? UISwitch
    }

    var isOn: Bool {
        get {
            `switch`?.isOn ?? false
        }

        set {
            `switch`?.isOn = newValue
        }
    }

    var switchOnTintColor: UIColor? {
        get {
            `switch`?.onTintColor
        }

        set {
            `switch`?.onTintColor = newValue
        }
    }

    var onSwitchValueChange: ((SwitchTableViewCell) -> Void)?

    override var accessoryView: UIView? {
        get {
            super.accessoryView
        }

        set {

        }
    }

    override var accessoryType: UITableViewCell.AccessoryType {
        get {
            super.accessoryType
        }

        set {

        }
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    private func setup() {
        setupSwitch()
        setupDefaults()
    }

    private func setupDefaults() {
        selectionStyle = .none
        tintColor = Theme.Color.secondary
        switchOnTintColor = Theme.Color.secondary
    }

    private func setupSwitch() {
        let `switch` = UISwitch()
        `switch`.addTarget(self, action: #selector(onSwitchChanged(_:)), for: .valueChanged)
        super.accessoryView = `switch`
    }

    override func prepareForReuse() {
        onSwitchValueChange = nil
        `switch`?.isOn = false
    }

    @objc
    private func onSwitchChanged(_ sender: UISwitch) {
        onSwitchValueChange?(self)
    }
}
