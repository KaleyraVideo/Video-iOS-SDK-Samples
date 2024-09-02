// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class AccessLinkViewController: UIViewController {

    private lazy var stack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [imageView, label])
        stack.axis = .vertical
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = 20
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView(image: Icons.linkBig)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()

    private lazy var label: UILabel = {
        let label = UILabel()
        label.text = Strings.AccessLink.message
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17)
        return label
    }()

    var onDismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground
        view.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leftAnchor.constraint(equalTo: view.layoutMarginsGuide.leftAnchor),
            stack.rightAnchor.constraint(equalTo: view.layoutMarginsGuide.rightAnchor),
            stack.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor)
        ])
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        onDismiss?()
    }
}
