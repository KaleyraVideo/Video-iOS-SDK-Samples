//
// Copyright © 2019-Present. Kaleyra S.p.a. All rights reserved.
//

import UIKit

protocol ContactTableViewCellDelegate: AnyObject {
    func contactTableViewCell(_ cell: ContactTableViewCell, didTouch chatButton: UIButton, withCounterpart aliasId: String)
}

class ContactTableViewCell: UITableViewCell {

    //MARK: - Properties

    weak var delegate: ContactTableViewCellDelegate?

    //MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var chatButton: UIButton!
    @IBOutlet weak var phoneImg: UIImageView!

    //MARK: - Actions
    @IBAction func didTouchChatButton(_ sender: UIButton) {
        if let id = subtitleLabel.text {
            delegate?.contactTableViewCell(self, didTouch: sender, withCounterpart: id)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        delegate = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
    }
}
