//
//  BasicInfoViewController.swift
//  Double
//
//  Created by James Pacheco on 12/6/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class BasicInfoViewController: UIViewController {

    var account: Account? = nil
    
    @IBOutlet weak var name1TextField: UITextField!
    @IBOutlet weak var person1DatePicker: UIDatePicker!
    @IBOutlet weak var gender1SegmentedControl: UISegmentedControl!
    @IBOutlet weak var name2TextField: UITextField!
    @IBOutlet weak var person2DatePicker: UIDatePicker!
    @IBOutlet weak var gender2SegmentedControl: UISegmentedControl!
    @IBOutlet weak var relationshipDatePicker: UIDatePicker!
    @IBOutlet weak var relationshipSegmentedControl: UISegmentedControl!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        guard let name1 = name1TextField.text where name1.characters.count > 0,
            let name2 = name2TextField.text where name2.characters.count > 0 else {presentAlert("Empty fields", message: "Please fill in all requested information. This will be shown in your profile"); return}
        
        let age1 = (person1DatePicker.date.timeIntervalSinceNow/(-365)/24/60/60)
        let age2 = (person2DatePicker.date.timeIntervalSinceNow/(-365)/24/60/60)
        guard age1 > 18 && age2 > 18 else {presentAlert("Not old enough", message: "Sorry - both partners need to be 18 or older to use this app."); return}
        
        let relationshipLength = relationshipDatePicker.date.timeIntervalSinceNow/(-365)/24/60/60
        guard relationshipLength > 0 else {presentAlert("Invalid relationship length", message: "Turns out we don't allow relationships that haven't started yet..."); return}
        
        let alert = UIAlertController(title: "Are you sure you want to continue?", message: "You won't be able to change the information above after you go to the next screen, and since all of it will show in your profile in some form or another, please just make sure it's all correct", preferredStyle: .ActionSheet)
        let editAction = UIAlertAction(title: "Something's wrong - let us fix it", style: .Cancel, handler: nil)
        let continueAction = UIAlertAction(title: "Everything looks good - let us finish putting together our profile", style: .Default) { (action) -> Void in
            self.performSegueWithIdentifier("fromBasicInfoToEditProfile", sender: self)
        }
        
        alert.addAction(editAction)
        alert.addAction(continueAction)
        presentViewController(alert, animated: true, completion: nil)
    }


    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromBasicInfoToEditProfile" {
            if let editProfileView = segue.destinationViewController as? EditProfileTableViewController {
                let gender1 = gender1SegmentedControl.selectedSegmentIndex == 0 ? "M":"F"
                let gender2 = gender2SegmentedControl.selectedSegmentIndex == 0 ? "M":"F"
                let person1 = Person(name: name1TextField.text!, dob: person1DatePicker.date, gender: Person.Gender(rawValue: gender1)!)
                let person2 = Person(name: name2TextField.text!, dob: person2DatePicker.date, gender: Person.Gender(rawValue: gender2)!)
                
                editProfileView.people = (person1, person2)
                editProfileView.relationshipStart = relationshipDatePicker.date
                editProfileView.relationshipStatus = relationshipSegmentedControl.selectedSegmentIndex
            }
        }
    }
    

}
