//
//  DetailedOptionTableViewCell.swift
//  TensionMaster
//
//  Created by Nikolay Markov on 5/4/19.
//  Copyright © 2019 Nikolay Markov. All rights reserved.
//

import UIKit

class DetailedOptionTableViewCell: DarkTableViewCell {

    @IBOutlet private var optionLabel: UILabel!
    @IBOutlet private var detailedLabel: UILabel!
    
    override var textLabel: UILabel? {
        get {
            return optionLabel
        }
    }
    override var detailTextLabel: UILabel? {
        get {
            return detailedLabel
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
