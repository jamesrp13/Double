//
//  BasicInfoViewController.swift
//  Double
//
//  Created by James Pacheco on 12/6/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class BasicInfoViewController: UIViewController, UITextFieldDelegate {

    var accountIdentifier: String? {
        get {
            return ProfileController.SharedInstance.currentUserIdentifier
        }
        
        set{}
    }
    
    @IBOutlet weak var name1TextField: UITextField!
    @IBOutlet weak var dob1TextField: UITextField!
    @IBOutlet weak var gender1SegmentedControl: UISegmentedControl!
    @IBOutlet weak var name2TextField: UITextField!
    @IBOutlet weak var dob2TextField: UITextField!
    @IBOutlet weak var gender2SegmentedControl: UISegmentedControl!
    @IBOutlet weak var relationshipStartTextField: UITextField!
    @IBOutlet weak var relationshipSegmentedControl: UISegmentedControl!
    
    var dob1: NSDate? = nil
    var dob2: NSDate? = nil
    var relationshipStart: NSDate? = nil
    
    var activeTextField: UITextField? = nil
    var genericDatePicker: UIDatePicker? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        
        let datePickerActionSheet = DatePickerActionSheet(parent: self, doneActionSelector: "datePickerInputFinished")
        genericDatePicker = datePickerActionSheet.datePicker
        dob1TextField.inputAccessoryView = datePickerActionSheet
        dob2TextField.inputAccessoryView = datePickerActionSheet
        relationshipStartTextField.inputAccessoryView = datePickerActionSheet
    }
    
    func datePickerInputFinished() {
        if let datePicker = genericDatePicker {
            if let textField = activeTextField {
                let date = datePicker.date
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateStyle = .MediumStyle
                dateFormatter.timeStyle = .NoStyle
                textField.text = dateFormatter.stringFromDate(date)
                
                switch textField {
                case dob1TextField:
                    dob1 = date
                case dob2TextField:
                    dob2 = date
                case relationshipStartTextField:
                    relationshipStart = date
                default:
                    break
                }
                
                textField.resignFirstResponder()
            }
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
        switch textField {
        case dob1TextField:
            genericDatePicker!.maximumDate = NSDate(timeIntervalSinceNow: (-18)*365*24*60*60)
            genericDatePicker!.date = genericDatePicker!.maximumDate!
        case dob2TextField:
            genericDatePicker!.maximumDate = NSDate(timeIntervalSinceNow: (-18)*365*24*60*60)
            genericDatePicker!.date = genericDatePicker!.maximumDate!
        case relationshipStartTextField:
            genericDatePicker!.maximumDate = NSDate()
            genericDatePicker!.date = genericDatePicker!.maximumDate!
        default:
            break
        }
        resignFirstResponderForOtherTextFields(textField)
    }
    
    func resignFirstResponderForOtherTextFields(textFieldInUse: UITextField) {
        if textFieldInUse != dob1TextField {
            dob1TextField.resignFirstResponder()
        }
        if textFieldInUse != dob2TextField {
            dob2TextField.resignFirstResponder()
        }
        if textFieldInUse != relationshipStartTextField {
            relationshipStartTextField.resignFirstResponder()
        }
        if textFieldInUse != name1TextField {
            name1TextField.resignFirstResponder()
        }
        if textFieldInUse != name2TextField {
            name2TextField.resignFirstResponder()
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        activeTextField = nil
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
            let name2 = name2TextField.text where name2.characters.count > 0,
            let dob1 = dob1,
            let dob2 = dob2,
            let relationshipStart = relationshipStart else {presentAlert("Empty fields", message: "Please fill in all requested information. This will be shown in your profile"); return}
        
        let age1 = (dob1.timeIntervalSinceNow/(-365)/24/60/60)
        let age2 = (dob2.timeIntervalSinceNow/(-365)/24/60/60)
        guard age1 > 18 && age2 > 18 else {presentAlert("Not old enough", message: "Sorry - both partners need to be 18 or older to use this app."); return}
        
        let relationshipLength = relationshipStart.timeIntervalSinceNow/(-365)/24/60/60
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

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        name1TextField.resignFirstResponder()
        name2TextField.resignFirstResponder()
        return true
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromBasicInfoToEditProfile" {
            if let editProfileView = segue.destinationViewController as? EditProfileTableViewController {
                let gender1 = gender1SegmentedControl.selectedSegmentIndex == 0 ? "M":"F"
                let gender2 = gender2SegmentedControl.selectedSegmentIndex == 0 ? "M":"F"
                let person1 = Person(name: name1TextField.text!, dob: dob1!, gender: Person.Gender(rawValue: gender1)!)
                let person2 = Person(name: name2TextField.text!, dob: dob2!, gender: Person.Gender(rawValue: gender2)!)
                let relationshipStatusInt = relationshipSegmentedControl.selectedSegmentIndex
                let relationshipStatus = relationshipStatusInt == 0 ? "Dating":(relationshipStatusInt == 1 ? "Engaged":"Married")
                
                
                editProfileView.people = (person1, person2)
                editProfileView.relationshipStart = relationshipStart!
                editProfileView.relationshipStatus = relationshipStatus
                editProfileView.accountIdentifier = accountIdentifier
            }
        }
    }
    

}
