// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import UIKit

final class NoContentView: UIView {

    enum Style {
        case message(text: String)
        case titleAndSubtitle(title: String, subtitle: String)
        case action(title: String, subtitle: String, actionTitle: String, action: () -> Void)

        fileprivate var title: String? {
            switch self {
                case .message(let text):
                    nil
                case .titleAndSubtitle(let title, _):
                    title
                case .action(let title, _, _, _):
                    title
            }
        }

        fileprivate var subtitle: String {
            switch self {
                case .message(let text):
                    text
                case .titleAndSubtitle(_, let subtitle):
                    subtitle
                case .action(_, let subtitle, _, _):
                    subtitle
            }
        }

        fileprivate var actionTitle: String? {
            guard case Style.action(_, _, let actionTitle, _) = self else {
                return nil
            }
            return actionTitle
        }

        fileprivate var action: (() -> Void)? {
            guard case Style.action(_, _, _, let action) = self else {
                return nil
            }
            return action
        }
    }

    let headerView: UIView
    let style: Style

    var title: String? {
        style.title
    }

    var subtitle: String? {
        style.subtitle
    }

    var actionTitle: String? {
        style.actionTitle
    }

    private var hasAction: Bool {
        guard case Style.action = style else { return false }
        return true
    }

    private var hasTitle: Bool {
        guard case Style.message = style else { return false }
        return true
    }

    private lazy var stack: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.alignment = .fill
        stack.spacing = 16
        stack.axis = .vertical
        return stack
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = style.title
        label.font = UIFont(name: "AvenirNext-Bold", size: 16)
        label.textAlignment = .center
        label.textColor = .black
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = style.subtitle
        label.font = UIFont(name: "Avenir", size: 14)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .black
        label.sizeToFit()
        return label
    }()

    private lazy var actionButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.minimumScaleFactor = 0.5
        button.titleLabel?.font = UIFont(name: "AvenirNext-Regular", size: 14)
        button.setTitle(style.actionTitle, for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = Theme.Color.secondary
        button.translatesAutoresizingMaskIntoConstraints = false
        button.sizeToFit()
        return button
    }()

    private lazy var buttonView: UIView = {
        let view = UIView(frame: .zero)

        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(actionButton)

        NSLayoutConstraint.activate([
            actionButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 0),
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            actionButton.heightAnchor.constraint(equalToConstant: 38),
            actionButton.widthAnchor.constraint(equalToConstant: 120),
            view.heightAnchor.constraint(equalToConstant: 38),
        ])

        actionButton.layer.cornerRadius = min(actionButton.frame.height, actionButton.frame.width)/2
        actionButton.addTarget(self, action: #selector(actionButtonClicked), for: .touchUpInside)

        return view
    }()

    init(style: Style, header: UIView, frame: CGRect = .zero) {
        self.headerView = header
        self.style = style

        super.init(frame: frame)

        setupView()
    }

    private func setupView() {
        addSubview(stack)

        stack.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stack.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            stack.centerXAnchor.constraint(equalTo: self.centerXAnchor)
        ])

        stack.addArrangedSubview(headerView)
        if hasTitle { stack.addArrangedSubview(titleLabel) }
        stack.addArrangedSubview(subtitleLabel)
        if hasAction { stack.addArrangedSubview(buttonView) }
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc 
    private func actionButtonClicked(_ sender: UIButton) {
        style.action?()
    }
}

