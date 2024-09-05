// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

extension UISearchBar {

    func simulateSearchTextChanged(_ text: String) {
        searchTextField.text = text
        delegate?.searchBar?(self, textDidChange: text)
    }

    func simulateCancel() {
        searchTextField.text = nil
        delegate?.searchBarCancelButtonClicked?(self)
    }
}
