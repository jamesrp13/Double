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
    var location: CLLocation? = nil
    
    var relationshipLength: String? {
        var lengthString = ""
        if let relationshipStart = relationshipStart,
            let relationshipStatus = relationshipStatus {
            let years = relationshipStart.timeIntervalSinceNow/(-365)/24/60/60
            let months = (relationshipStart.timeIntervalSinceNow)/(-24)/60/60/30
            let yearsRounded = Int(round(years))
            let monthsRounded = Int(round(months))
            if years < 1 {
                if monthsRounded == 0 {
                    switch relationshipStatus {
                        case "dating":
                        lengthString = "just started dating"
                        case "married":
                        lengthString = "just got married"
                        case "engaged":
                        lengthString = "just got engaged"
                    default:
                        lengthString = "just started dating"
                    }
                } else {
                    lengthString = monthsRounded == 1 ? "have been \(relationshipStatus) for \(monthsRounded) month":"have been \(relationshipStatus) for \(monthsRounded) months"
                }
            } else {
                if months%12 >= 4 && months%12 <= 8 {
                    lengthString = "have been \(relationshipStatus) for \(yearsRounded) and a half years"
                } else {
                    lengthString = yearsRounded == 1 ? "have been \(relationshipStatus) for \(yearsRounded) year":"have been \(relationshipStatus) for \(yearsRounded) years"
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
        self.relationshipStart = profile.relationshipStart
        self.relationshipStatus = profile.relationshipStatus.rawValue.lowercaseString
        self.location = profile.location
        if let relationshipLength = relationshipLength {
            guard let location = location else {return}
            LocationController.locationAsCityCountry(location, completion: { (cityState) -> Void in
                guard let cityState = cityState else {return}
                if let children = profile.children where children.count > 0 {
                    self.aboutLabel.text = "\(person1.name) and \(person2.name) \(relationshipLength), have \(children.count) \(children.count == 1 ? "child":"children") and live in \(cityState)."
                } else {
                    self.aboutLabel.text = "\(person1.name) and \(person2.name) \(relationshipLength) and live in \(cityState)."
                }
            })
        }
    }
    
    func updateWithPeople(people: (Person, Person), relationshipStatus: String, relationshipStart: NSDate) {
        self.relationshipStart = relationshipStart
        self.relationshipStatus = relationshipStatus.lowercaseString
        if let relationshipLength = relationshipLength {
            aboutLabel.text = "\(people.0.name) and \(people.1.name) \(relationshipLength)."
        }
    }
    
}
