// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class ButtonTableFooter: UIView {

    private lazy var button: RoundedButton = {
        let button = RoundedButton(frame: .init(x: 0, y: 0, width: 100, height: 50))
        button.addTarget(self, action: #selector(onButtonTouched(_:)), for: .touchUpInside)
        button.backgroundColor = Theme.Color.secondary
        button.setTitle(title, for: .normal)
        button.setTitleColor(Theme.Color.commonWhiteColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let title: String
    private let action: () -> Void

    init(title: String, action: @escaping () -> Void) {
        self.title = title
        self.action = action
        super.init(frame: .init(x: 0, y: 0, width: 100, height: 70))
        setup()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("Not available")
    }

    func enableButton() {
        button.isEnabled = true
    }

    func disableButton() {
        button.isEnabled = false
    }

    private func setup() {
        addSubview(button)
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(greaterThanOrEqualTo: topAnchor),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            button.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            button.bottomAnchor.constraint(lessThanOrEqualTo: bottomAnchor),
        ])
    }

    @objc
    private func onButtonTouched(_ sender: UIButton) {
        action()
    }
}
