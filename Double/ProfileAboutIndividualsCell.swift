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
    @IBOutlet weak var firstPersonAboutTextView: UITextView!
    @IBOutlet weak var secondPersonAboutTextView: UITextView!
    
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
        
        if firstPersonAboutLabel != nil {
            if let firstPersonAbout = person1.about {
                firstPersonAboutLabel.text = firstPersonAbout
            }
            
            if let secondPersonAbout = person2.about {
                secondPersonAboutLabel.text = secondPersonAbout
            }
            
            firstPersonNameLabel.text = "\(person1.name) (\(person1.age)-\(person1.gender.rawValue)):"
            
            secondPersonNameLabel.text = "\(person2.name) (\(person2.age)-\(person2.gender.rawValue)):"
        } else if firstPersonAboutTextView != nil {
            if let firstPersonAbout = person1.about {
                firstPersonAboutTextView.text = firstPersonAbout
            }
            
            if let secondPersonAbout = person2.about {
                secondPersonAboutTextView.text = secondPersonAbout
            }
            
            firstPersonNameLabel.text = "\(person1.name) (\(person1.age)-\(person1.gender.rawValue)):"
            
            secondPersonNameLabel.text = "\(person2.name) (\(person2.age)-\(person2.gender.rawValue)):"
        }
    }
    
    func updateWithPeople(people: (Person, Person)) {
        firstPersonNameLabel.text = "\(people.0.name) (\(people.0.age)-\(people.0.gender.rawValue)):"
        secondPersonNameLabel.text = "\(people.1.name) (\(people.1.age)-\(people.1.gender.rawValue)):"
        
        if firstPersonAboutLabel != nil {
            if let firstPersonAbout = people.0.about {
                firstPersonAboutLabel.text = firstPersonAbout
            }
            
            if let secondPersonAbout = people.1.about {
                secondPersonAboutLabel.text = secondPersonAbout
            }
        } else if firstPersonAboutTextView != nil {
            if let firstPersonAbout = people.0.about {
                firstPersonAboutTextView.text = firstPersonAbout
            }
            
            if let secondPersonAbout = people.1.about {
                secondPersonAboutTextView.text = secondPersonAbout
            }
        }

    }

}
