//
//  Copyright © 2019-2021 Bandyer. All rights reserved.
//

import UIKit

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
        } else if indexPath.section == 1 {
            if indexPath.row == 0 {
                let recordingSwitch = cell.accessoryView as? UISwitch
                recordingSwitch?.isOn = self.options.record
            } else if indexPath.row == 1 {
                let textField = cell.accessoryView as? UITextField
                textField?.text = String(self.options.maximumDuration)
            }
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if indexPath.section == 0 {
            switch indexPath.row {
            case 0: options.type = .audioVideo
            case 1: options.type = .audioUpgradable
            case 2: options.type = .audioOnly
            default: options.type = .audioVideo
            }

            tableView.reloadData()
            delegate?.controllerDidUpdateOptions(self)
        }
    }

    @IBAction func recordingSwitchValueChanged(sender: AnyObject) {
        guard let `switch` = sender as? UISwitch else {
            return
        }
        options.record = `switch`.isOn
        tableView.reloadData()
        delegate?.controllerDidUpdateOptions(self)
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
