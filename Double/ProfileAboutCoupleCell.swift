//
//  ProfileAboutCoupleCell.swift
//  Double
//
//  Created by James Pacheco on 11/20/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class ProfileAboutCoupleCell: UITableViewCell {

    @IBOutlet weak var aboutLabel: UILabel!
    
    var relationshipStatus: String? = nil
    var relationshipStart: NSDate? = nil
    
    var relationshipLength: String? {
        var lengthString = ""
        if let relationshipStart = relationshipStart {
            let years = relationshipStart.timeIntervalSinceNow/(-365)/24/60/60
            let months = (relationshipStart.timeIntervalSinceNow)/(-24)/60/60/30
            if years < 1 {
                lengthString = Int(round(months)) == 1 ? "\(Int(round(months))) month":"\(Int(round(months))) months"
            } else {
                if months%12 >= 4 && months%12 <= 8 {
                    lengthString = "\(Int(round(years))) and a half years"
                } else {
                    lengthString = Int(round(years)) == 1 ? "\(Int(round(years))) year":"\(Int(round(years))) years"
                }
            }
        }
        return lengthString
    }

    
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
        let relationshipStatus = profile.relationshipStatus
        if let relationshipLength = profile.relationshipLength {
            aboutLabel.text = "\(person1.name) and \(person2.name) have been \(relationshipStatus) for \(relationshipLength)."
        }
    }
    
    func updateWithPeople(people: (Person, Person), relationshipStatus: String, relationshipStart: NSDate) {
        self.relationshipStart = relationshipStart
        self.relationshipStatus = relationshipStatus
        if let relationshipLength = relationshipLength {
            aboutLabel.text = "\(people.0.name) and \(people.1.name) have been \(relationshipStatus) for \(relationshipLength)."
        }
    }
    
}
