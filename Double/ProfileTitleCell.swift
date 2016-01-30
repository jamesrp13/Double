//
//  EvaluateTableViewCell.swift
//  Double
//
//  Created by James Pacheco on 11/20/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class ProfileTitleCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

    func updateWithProfile(profile: Profile) {
        let person1 = profile.people.0
        let person2 = profile.people.1
        titleLabel.text = "\(person1.name) and \(person2.name)"
    }
    
    func update() {
        titleLabel.text = "Really long title that requires word wrapping and maybe automatic increase in row height"
    }
    
}

protocol ProfileTitleCellDelegate {
    func heightForCell() -> CGFloat
}
