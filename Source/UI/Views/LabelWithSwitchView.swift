// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

class LabelWithSwitchView: UIView {

    private lazy var label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var `switch`: UISwitch = {
        let control = UISwitch()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.addTarget(self, action: #selector(onSwitchValueChanged(_:)), for: .valueChanged)
        control.onTintColor = Theme.Color.secondary
        return control
    }()

    // MARK: - Properties

    @Proxy(\.label.text)
    var text: String?

    @Proxy(\.switch.isOn)
    var isOn: Bool

    var onValueChange: ((Bool) -> Void)?

    // MARK: - Init

    init(text: String, isOn: Bool) {
        super.init(frame: .zero)

        setup(text: text, isOn: isOn)
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup(text: nil, isOn: false)
    }

    private func setup(text: String?, isOn: Bool) {
        self.text = text
        self.isOn = isOn
        setupHierarchy()
        setupConstraints()
    }

    private func setupHierarchy() {
        addSubview(label)
        addSubview(`switch`)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            label.leftAnchor.constraint(equalTo: layoutMarginsGuide.leftAnchor),
            label.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),
            `switch`.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            `switch`.rightAnchor.constraint(equalTo: layoutMarginsGuide.rightAnchor),
        ])
    }

    // MARK: - Switch value changed

    @objc
    private func onSwitchValueChanged(_ sender: UISwitch) {
        onValueChange?(sender.isOn)
    }
}
