//
// Created by Luca Tagliabue on 2019-10-11.
// Copyright (c) 2019 Bandyer. All rights reserved.
//

import UIKit

protocol ContactTableViewCellDelegate: class {
    func contactTableViewCell(_ cell:  ContactTableViewCell, didTouch chatButton: UIButton, withCounterpart aliasId: String)
}

class ContactTableViewCell: UITableViewCell {

    //MARK: - Properties

    weak var delegate: ContactTableViewCellDelegate?

    //MARK: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var chatButton: UIButton!

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
