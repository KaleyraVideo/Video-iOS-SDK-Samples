// Copyright © 2018-2022 Kaleyra S.p.a. All Rights Reserved.
// See LICENSE.txt for licensing information

import UIKit

extension UIViewController {
    func showAlertMessage(title: String, message: String, buttonTitle: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))

        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
    }

    func showAlertMessageWithAction(title: String,
                                    message: String,
                                    buttonTitle: String,
                                    buttonActionTitle: String,
                                    buttonActionHandler: @escaping () -> Void) {

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: buttonTitle, style: .default, handler: nil))
        alert.addAction(UIAlertAction(title: buttonActionTitle, style: .destructive, handler: { _ in
            buttonActionHandler()
        }))

        alert.popoverPresentationController?.sourceView = self.view
        self.present(alert, animated: true, completion: nil)
    }
}
