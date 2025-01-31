// Copyright © 2018-2025 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

protocol ReusableView {

    static var reuseIdentifier: String { get }
}

extension ReusableView {

    static var reuseIdentifier: String { String(describing: self) }
}

extension UICollectionView {

    func registerReusableCell<T: UICollectionViewCell>(_ cell: T.Type) {
        register(cell, forCellWithReuseIdentifier: T.reuseIdentifier)
    }

    func dequeueReusableCell<T: UICollectionViewCell>(_ type: T.Type = T.self, for indexPath: IndexPath) -> T {
        dequeueReusableCell(withReuseIdentifier: T.reuseIdentifier, for: indexPath) as! T
    }
}

extension UICollectionViewCell: ReusableView {}
