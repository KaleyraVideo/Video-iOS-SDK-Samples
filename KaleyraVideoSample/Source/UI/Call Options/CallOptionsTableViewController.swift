//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import Foundation
import UIKit
import KaleyraVideoSDK

@objc protocol CallOptionsTableViewControllerDelegate {
    func controllerDidUpdateOptions(_ controller: CallOptionsTableViewController) -> Void
}

class CallOptionsTableViewController: UITableViewController {

    @IBOutlet var delegate: CallOptionsTableViewControllerDelegate?

    var options = CallOptionsItem()

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if indexPath.section == 0 {
            cell.accessoryType = indexPath.row == self.options.type.rawValue ? .checkmark : .none
        } else if indexPath.section  == 1 {
            cell.accessoryType = indexPath.row == self.options.recordingType.rawValue ? .checkmark : .none
        } else if indexPath.section == 2 {
            let textField = cell.accessoryView as? UITextField
            textField?.text = String(self.options.maximumDuration)
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 || indexPath.section == 1 {
            if indexPath.section == 0 {
                switch indexPath.row {
                    case 0: options.type = .audioVideo
                    case 1: options.type = .audioUpgradable
                    case 2: options.type = .audioOnly
                    default: options.type = .audioVideo
                }
            } else if indexPath.section == 1 {
                switch indexPath.row {
                    case 0: options.recordingType = .none
                    case 1: options.recordingType = .automatic
                    case 2: options.recordingType = .manual
                    default: options.recordingType = .none
                }
            }

            tableView.reloadData()
            delegate?.controllerDidUpdateOptions(self)
        }
    }
    
}

extension CallOptionsTableViewController: UITextFieldDelegate {

    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, let value = UInt(text) else {
            return
        }

        options.maximumDuration = value
        tableView.reloadData()
        delegate?.controllerDidUpdateOptions(self)
    }
}

private extension CallOptions.CallType {

    var rawValue: Int {
        switch self {
            case .audioVideo:
                0
            case .audioUpgradable:
                1
            case .audioOnly:
                2
        }
    }
}

private extension Optional where Wrapped == CallOptions.RecordingType {

    var rawValue: Int {
        switch self {
            case .none:
                return 0
            case .some(let wrapped):
                switch wrapped {
                    case .automatic:
                        return 1
                    case .manual:
                        return 2
                }
        }
    }
}
