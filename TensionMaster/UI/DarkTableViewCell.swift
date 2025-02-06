//
//  DarkTableViewCell.swift
//  TensionMaster
//
//  Created by Nikolay Markov on 2/8/19.
//  Copyright © 2019 Nikolay Markov. All rights reserved.
//

import UIKit

class DarkTableViewCell: UITableViewCell {

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        selectedBackgroundView = UIView()
        selectedBackgroundView?.backgroundColor = UIColor.backgroundDark
        tintColor = UIColor.accent
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
