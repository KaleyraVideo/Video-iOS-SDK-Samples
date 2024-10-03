// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

final class SettingsCell: UITableViewCell {

    enum CellStyle {
        case normal
        case danger
    }

    var cellStyle: CellStyle = .normal {
        didSet {
            refreshLabelTextColor()
        }
    }

    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    }()

    convenience init() {
        self.init(reuseIdentifier: nil)
    }

    convenience init(reuseIdentifier: String?) {
        self.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("Not available")
    }

    private func setup() {
        setupBackgroundView()
        setupLabels()
    }

    private func setupBackgroundView() {
        selectedBackgroundView = bgView
    }

    private func setupLabels() {
        textLabel?.font = .systemFont(ofSize: 18)
        detailTextLabel?.font = .systemFont(ofSize: 16)
        refreshLabelTextColor()
    }

    private func refreshLabelTextColor() {
        textLabel?.textColor = cellStyle == .danger ? .red : .label
    }
}
