// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

class ExpandableTableViewCell: UITableViewCell {

    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var collapsedContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()

    private lazy var expandedContainer: BottomContainer = {
        let view = BottomContainer()
        view.accessibilityIdentifier = "bottomContainer"
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()

    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [collapsedContainer, expandedContainer])
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .vertical
        stack.distribution = .fill
        stack.alignment = .fill
        stack.spacing = 10
        return stack
    }()

    // MARK: - Content

    var expandedContent: UIView! {
        get {
            expandedContainer.contentView
        }

        set {
            expandedContainer.contentView = newValue
        }
    }

    // MARK: - Properties

    var title: String? {
        get {
            titleLabel.text
        }

        set {
            titleLabel.text = newValue
        }
    }

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
        setupHierarchy()
        setupConstraints()
    }

    private func setupHierarchy() {
        contentView.addSubview(stack)
        collapsedContainer.addSubview(titleLabel)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: collapsedContainer.topAnchor, constant: 10),
            titleLabel.leftAnchor.constraint(equalTo: collapsedContainer.leftAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: collapsedContainer.bottomAnchor, constant: -10),
            stack.topAnchor.constraint(equalTo: contentView.layoutMarginsGuide.topAnchor),
            stack.leftAnchor.constraint(equalTo: contentView.layoutMarginsGuide.leftAnchor),
            stack.rightAnchor.constraint(equalTo: contentView.layoutMarginsGuide.rightAnchor),
            stack.bottomAnchor.constraint(equalTo: contentView.layoutMarginsGuide.bottomAnchor),
        ])
    }

    // MARK: - Expand / Collapse

    func expand() {
        expandedContainer.isHidden = false
    }

    func collapse() {
        expandedContainer.isHidden = true
    }
}

private class BottomContainer: UIView {

    private lazy var divider: UIView = {
        let view = UIView(frame: .init(origin: .zero, size: .init(width: 1, height: 1)))
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        return view
    }()

    var contentView: UIView! {
        willSet {
            contentView?.removeFromSuperview()
        }

        didSet {
            addSubview(contentView)
            contentView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                contentView.topAnchor.constraint(equalTo: divider.bottomAnchor, constant: 10),
                contentView.leftAnchor.constraint(equalTo: leftAnchor),
                contentView.rightAnchor.constraint(equalTo: rightAnchor),
                contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        }
    }

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)

        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        setup()
    }

    private func setup() {
        setupHierarchy()
        setupConstraints()
    }

    private func setupHierarchy() {
        addSubview(divider)
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            divider.topAnchor.constraint(equalTo: topAnchor),
            divider.leftAnchor.constraint(equalTo: leftAnchor),
            divider.rightAnchor.constraint(equalTo: rightAnchor),
            divider.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
}
