//
//  ProfileAboutCoupleCell.swift
//  Double
//
//  Created by James Pacheco on 11/20/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class ProfileAboutCoupleCell: UITableViewCell, UITextViewDelegate {
    
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    
    var relationshipStatus: String? = nil
    var relationshipStart: NSDate? = nil
    var children: [Child] = []
    var location: CLLocation? = nil
    var parentTableViewController: EditProfileTableViewController? = nil
    
    var relationshipLength: String? {
        var lengthString = ""
        if let relationshipStart = relationshipStart,
            let relationshipStatus = relationshipStatus {
                let calendar = NSCalendar.currentCalendar()
                let lengthComponents = calendar.components(.Month, fromDate: relationshipStart, toDate: NSDate(), options: .MatchFirst)
                
                let years = lengthComponents.month/12
                let months = lengthComponents.month
                if years < 1 {
                    if months == 0 {
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
                        lengthString = months == 1 ? "have been \(relationshipStatus) for \(months) month":"have been \(relationshipStatus) for \(months) months"
                    }
                } else {
                    if months%12 >= 4 && months%12 <= 8 {
                        lengthString = "have been \(relationshipStatus) for \(years) and a half years"
                    } else {
                        lengthString = years == 1 ? "have been \(relationshipStatus) for \(years) year":"have been \(relationshipStatus) for \(years) years"
                    }
                }
        }
        return lengthString
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if aboutTextView != nil {
            aboutTextView.delegate = self
            aboutTextView.inputView = UIView()
        }
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateWithProfile(profile: Profile) {
        self.relationshipStart = profile.relationshipStart
        self.relationshipStatus = profile.relationshipStatus.rawValue.lowercaseString
        self.location = profile.location
        self.children = profile.children ?? []
        
        guard let relationshipLength = relationshipLength,
            location = self.location else {return}
        let people = profile.people
        
        if let cityState = profile.locationAsString {
            var childString: String = ""
            var description: String = ""
            if self.children.count > 0 && self.children.count < 5 {
                for var i=0; i<self.children.count; i++ {
                    let child = self.children[i]
                    let gender = child.gender.rawValue == "M" ? "son":"daughter"
                    var childAgeString: String = ""
                    if child.age < 12 {
                        childAgeString = "\(child.age) month old"
                    } else {
                        childAgeString = "\(child.age/12) year old"
                    }
                    
                    if childString.characters.count > 0 {
                        if self.children.count > 2 {
                            childString += ", "
                        } else {
                            childString += " "
                        }
                        if i+1 == self.children.count {
                            childString += "and "
                        }
                    }
                    childString += "\(childAgeString) \(gender)"
                }
                description = "\(people.0.name) and \(people.1.name) \(relationshipLength) and live in \(cityState) with their \(childString)."
            } else if self.children.count >= 5 {
                childString = "\(self.children.count) children"
                description = "\(people.0.name) and \(people.1.name) \(relationshipLength) and live in \(cityState) with their \(childString)."
            } else {
                description = "\(people.0.name) and \(people.1.name) \(relationshipLength) and live in \(cityState)."
            }
            
            if self.aboutLabel != nil {
                self.aboutLabel.text = description
                //self.resizeCellsBasedOnLabel(self.aboutLabel)
            } else if self.aboutTextView != nil {
                self.aboutTextView.text = description
                //self.resizeCellsBasedOnTextView(self.aboutTextView)
            }

        } else {
            
            LocationController.locationAsCityCountry(location, completion: { (cityState) -> Void in
                guard let cityState = cityState else {return}
                var childString: String = ""
                var description: String = ""
                if self.children.count > 0 && self.children.count < 5 {
                    for var i=0; i<self.children.count; i++ {
                        let child = self.children[i]
                        let gender = child.gender.rawValue == "M" ? "son":"daughter"
                        var childAgeString: String = ""
                        if child.age < 12 {
                            childAgeString = "\(child.age) month old"
                        } else {
                            childAgeString = "\(child.age/12) year old"
                        }
                        
                        if childString.characters.count > 0 {
                            if self.children.count > 2 {
                                childString += ", "
                            } else {
                                childString += " "
                            }
                            if i+1 == self.children.count {
                                childString += "and "
                            }
                        }
                        childString += "\(childAgeString) \(gender)"
                    }
                    description = "\(people.0.name) and \(people.1.name) \(relationshipLength) and live in \(cityState) with their \(childString)."
                } else if self.children.count >= 5 {
                    childString = "\(self.children.count) children"
                    description = "\(people.0.name) and \(people.1.name) \(relationshipLength) and live in \(cityState) with their \(childString)."
                } else {
                    description = "\(people.0.name) and \(people.1.name) \(relationshipLength) and live in \(cityState)."
                }
                
                if self.aboutLabel != nil {
                    self.aboutLabel.text = description
                    self.resizeCellsBasedOnLabel(self.aboutLabel)
                } else if self.aboutTextView != nil {
                    self.aboutTextView.text = description
                    self.resizeCellsBasedOnTextView(self.aboutTextView)
                }
            })
        }
    }
    
    func updateWithPeople(people: (Person, Person), relationshipStatus: String, relationshipStart: NSDate, children: [Child], location: CLLocation) {
        self.relationshipStart = relationshipStart
        self.relationshipStatus = relationshipStatus.lowercaseString
        self.location = location
        self.children = children
        
        guard let relationshipLength = relationshipLength,
            location = self.location else {return}
        
        LocationController.locationAsCityCountry(location, completion: { (cityState) -> Void in
            guard let cityState = cityState else {return}
            var childString: String = ""
            var description: String = ""
            if children.count > 0 && children.count < 5 {
                for var i=0; i<children.count; i++ {
                    let child = children[i]
                    let gender = child.gender.rawValue == "M" ? "son":"daughter"
                    var childAgeString: String = ""
                    if child.age < 12 {
                        childAgeString = "\(child.age) month old"
                    } else {
                        childAgeString = "\(child.age/12) year old"
                    }

                    if childString.characters.count > 0 {
                        if children.count > 2{
                            childString += ", "
                        }
                        if i+1 == children.count {
                            childString += "and "
                        }
                    }
                    childString += "\(childAgeString) \(gender)"
                }
                description = "\(people.0.name) and \(people.1.name) \(relationshipLength) and live in \(cityState) with their \(childString)."
            } else if children.count >= 5 {
                childString = "\(children.count) children"
                description = "\(people.0.name) and \(people.1.name) \(relationshipLength) and live in \(cityState) with their \(childString)."
            } else {
                description = "\(people.0.name) and \(people.1.name) \(relationshipLength) and live in \(cityState)."
            }
            
            if self.aboutLabel != nil {
                self.aboutLabel.text = description
                self.resizeCellsBasedOnLabel(self.aboutLabel)
            } else if self.aboutTextView != nil {
                self.aboutTextView.text = description
                self.resizeCellsBasedOnTextView(self.aboutTextView)
            }
        })
    }
    
    func textViewDidBeginEditing(textView: UITextView) {

        textView.resignFirstResponder()
        
        if textView == aboutTextView {
            if let parentTableViewController = parentTableViewController {
                parentTableViewController.displayBasicInfoPopoverViewController()
            }
        }
    }
}

extension UITableViewCell {
    /// Search up the view hierarchy of the table view cell to find the containing table view
    var tableView: UITableView? {
        get {
            var table: UIView? = superview
            while !(table is UITableView) && table != nil {
                table = table?.superview
            }
            
            return table as? UITableView
        }
    }
    
    func resizeCellsBasedOnTextView(textView: UITextView) {
        textView.sizeThatFits(CGSize(width: textView.bounds.size.width, height: CGFloat.max))
        UIView.setAnimationsEnabled(false)
        self.tableView?.beginUpdates()
        self.tableView?.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
    func resizeCellsBasedOnLabel(label: UILabel) {
        label.sizeThatFits(CGSize(width: label.bounds.size.width, height: CGFloat.max))
        UIView.setAnimationsEnabled(false)
        self.tableView?.beginUpdates()
        self.tableView?.endUpdates()
        UIView.setAnimationsEnabled(true)
    }
    
}
