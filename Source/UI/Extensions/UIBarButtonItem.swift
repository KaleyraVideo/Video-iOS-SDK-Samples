// Copyright © 2018-2023 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE for licensing information

import Foundation
import UIKit

extension UIBarButtonItem {

    private final class Trampoline: NSObject {

        let action: () -> Void

        init(action: @escaping () -> Void) {
            self.action = action
        }

        @objc
        func invoke() {
            action()
        }
    }

    convenience init(title: String?, style: Style, action: @escaping () -> Void) {
        let trampoline = Trampoline(action: action)
        self.init(title: title, style: style, target: trampoline, action: #selector(trampoline.invoke))
        let key = UnsafeMutablePointer<Int8>.allocate(capacity: 1)
        objc_setAssociatedObject(self, key, trampoline, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }

    convenience init(image: UIImage?, style: Style, action: @escaping () -> Void) {
        let trampoline = Trampoline(action: action)
        self.init(image: image, style: style, target: trampoline, action: #selector(trampoline.invoke))
        let key = UnsafeMutablePointer<Int8>.allocate(capacity: 1)
        objc_setAssociatedObject(self, key, trampoline, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}
