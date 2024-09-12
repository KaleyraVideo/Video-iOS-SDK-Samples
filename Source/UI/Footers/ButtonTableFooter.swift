// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class ButtonTableFooter: UIView {

    private lazy var button: RoundedButton = {
        let button = RoundedButton(frame: .init(x: 0, y: 0, width: 150, height: 50))
        button.addTarget(self, action: #selector(onButtonTouched(_:)), for: .touchUpInside)
        button.backgroundColor = Theme.Color.secondary
        button.setTitleColor(Theme.Color.commonWhiteColor, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    var buttonTitle: String? {
        get {
            button.title(for: .normal)
        }

        set {
            button.setTitle(newValue, for: .normal)
        }
    }

    var buttonAction: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: frame)
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
            button.topAnchor.constraint(equalTo: topAnchor),
            button.leftAnchor.constraint(equalTo: leftAnchor, constant: 20),
            button.rightAnchor.constraint(equalTo: rightAnchor, constant: -20),
            button.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }

    @objc
    private func onButtonTouched(_ sender: UIButton) {
        buttonAction?()
    }
}
