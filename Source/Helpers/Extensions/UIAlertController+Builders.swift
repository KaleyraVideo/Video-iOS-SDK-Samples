// Copyright © 2018-2024 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

extension UIAlertController {

    @inlinable
    public static func alert(title: String? = nil, message: String? = nil) -> UIAlertController {
        .init(title: title, message: message, preferredStyle: .alert)
    }

    @inlinable
    public static func actionSheet(title: String? = nil, message: String? = nil) -> UIAlertController {
        .init(title: title, message: message, preferredStyle: .actionSheet)
    }
}

extension UIAlertAction {

    @inlinable
    public static func `default`(title: String, handler: @escaping (UIAlertAction) -> Void) -> UIAlertAction {
        .init(title: title, style: .default, handler: handler)
    }

    @inlinable
    public static func `default`(title: String, handler: @escaping () -> Void) -> UIAlertAction {
        .init(title: title, style: .default, handler: { _ in handler() })
    }

    @inlinable
    public static func cancel(title: String, handler: ((UIAlertAction) -> Void)? = nil) -> UIAlertAction {
        .init(title: title, style: .cancel, handler: handler)
    }

    @inlinable
    public static func cancel(title: String, handler: @escaping () -> Void) -> UIAlertAction {
        .init(title: title, style: .cancel, handler: { _ in handler() })
    }

    @inlinable
    public static func destructive(title: String, handler: @escaping (UIAlertAction) -> Void) -> UIAlertAction {
        .init(title: title, style: .destructive, handler: handler)
    }

    @inlinable
    public static func destructive(title: String, handler: @escaping () -> Void) -> UIAlertAction {
        .init(title: title, style: .destructive, handler: { _ in handler() })
    }
}
