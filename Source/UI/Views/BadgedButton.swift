// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class BadgedButton: UIButton {

    private lazy var badgeView: BadgeView = {
        let badge = BadgeView()
        badge.translatesAutoresizingMaskIntoConstraints = false
        badge.backgroundColor = .init(rgb: 0x1E1B86)
        return badge
    }()

    var badgeValue: UInt? {
        didSet {
            guard badgeValue != oldValue else { return }

            if let badgeValue {
                badgeView.setBadgeValue(badgeValue)

                guard badgeView.superview == nil else { return }

                addSubview(badgeView)
                NSLayoutConstraint.activate([
                    badgeView.centerXAnchor.constraint(equalTo: rightAnchor, constant: -6),
                    badgeView.centerYAnchor.constraint(equalTo: topAnchor, constant: 1)
                ])
            } else {
                badgeView.removeFromSuperview()
            }
        }
    }

    private final class BadgeView: UIView {

        private lazy var label: UILabel = {
            let label = UILabel()
            label.translatesAutoresizingMaskIntoConstraints = false
            label.numberOfLines = 1
            label.lineBreakMode = .byTruncatingMiddle
            label.textAlignment = .center
            label.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: UIFont.systemFont(ofSize: 12))
            label.textColor = .white
            return label
        }()

        @Proxy(\.label.text)
        private var value: String?

        override init(frame: CGRect) {
            super.init(frame: frame)
            setup()
        }

        required init?(coder: NSCoder) {
            super.init(coder: coder)
            setup()
        }

        private func setup() {
            layer.masksToBounds = true
            addSubview(label)
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: topAnchor, constant: 1.5),
                label.leftAnchor.constraint(equalTo: leftAnchor, constant: 3),
                label.rightAnchor.constraint(equalTo: rightAnchor, constant: -3),
                label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -1.5)
            ])
        }

        func setBadgeValue(_ value: UInt?) {
            self.value = if let value {
                value > 99 ? "99+" : "\(value)"
            } else {
                nil
            }
        }

        override func layoutSubviews() {
            super.layoutSubviews()

            layer.cornerRadius = bounds.height / 2
        }
    }
}
