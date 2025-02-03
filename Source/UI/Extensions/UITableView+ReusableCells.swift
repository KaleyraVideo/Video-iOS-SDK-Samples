// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import Foundation
import UIKit

protocol IdentifiableUITableViewCell {

    static var reuseIdentifier: String { get }
}

extension UITableViewCell: IdentifiableUITableViewCell {

    static var reuseIdentifier: String {
        String(describing: self)
    }
}

extension UITableView {

    func registerReusableCell<T>(_ cell: T.Type) where T:UITableViewCell {
        register(cell, forCellReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T>(_ type: T.Type = T.self, for indexPath: IndexPath) -> T where T: UITableViewCell {
        dequeueReusableCell(withIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}
