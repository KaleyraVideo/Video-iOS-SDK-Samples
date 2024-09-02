// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit
@testable import SDK_Sample

extension TextFieldTableViewCell {

    var textField: UITextField? {
        firstDescendant()
    }

    func simulateTextChanged(_ text: String) {
        textField?.text = text
        textField?.sendActions(for: .editingChanged)
    }

    func simulateTextEditingEnded(_ text: String) {
        textField?.text = text
        textField?.sendActions(for: .editingDidEnd)
    }
}
