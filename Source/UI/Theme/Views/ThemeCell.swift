// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

#if SAMPLE_CUSTOMIZABLE_THEME

import Foundation
import UIKit

class ThemeCell: UITableViewCell, Themable {

    private lazy var bgView: UIView = {
        UIView()
    }()

    convenience init() {
        self.init(style: .default, reuseIdentifier: nil)
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setup()
    }

    private func setup() {
        selectedBackgroundView = bgView
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("Not available")
    }

    func themeChanged(theme: AppTheme) {
        backgroundColor = theme.primaryBackgroundColor.toUIColor()
        bgView.backgroundColor = theme.tertiaryBackgroundColor.toUIColor()
        tintColor = theme.accentColor.toUIColor()
        textLabel?.font = theme.font != nil ? theme.font?.toUIFont() : UIFont.systemFont(ofSize: 18)
        textLabel?.textColor = (backgroundColor?.isLight ?? true) ? .black : .white
    }
}

#endif
