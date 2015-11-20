//
//  ProfileAboutIndividualsCell.swift
//  Double
//
//  Created by James Pacheco on 11/20/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class ProfileAboutIndividualsCell: UITableViewCell {

    @IBOutlet weak var firstPersonNameLabel: UILabel!
    @IBOutlet weak var secondPersonNameLabel: UILabel!
    @IBOutlet weak var firstPersonAboutLabel: UILabel!
    @IBOutlet weak var secondPersonAboutLabel: UILabel!
    
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
        if let firstPersonAbout = person1.about {
            firstPersonAboutLabel.text = firstPersonAbout
        }
        
        if let secondPersonAbout = person2.about {
            secondPersonAboutLabel.text = secondPersonAbout
        }
        
        firstPersonNameLabel.text = "\(person1.name) (\(person1.age)-\(person1.gender.rawValue))"
        
        secondPersonNameLabel.text = "\(person2.name) (\(person2.age)-\(person2.gender.rawValue))"
    }

}
