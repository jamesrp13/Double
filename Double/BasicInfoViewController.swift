//
//  BasicInfoViewController.swift
//  Double
//
//  Created by James Pacheco on 12/6/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit
import CoreLocation

class BasicInfoViewController: UIViewController, UITextFieldDelegate {
    
    var accountIdentifier: String? {
        get {
            return ProfileController.SharedInstance.currentUserIdentifier
        }
        
        set{}
    }
    
    enum State {
        case first
        case second
        case couple
    }
    
    var state: State = State.first
    
    @IBOutlet weak var firstPersonStackView: UIStackView!
    @IBOutlet weak var secondPersonStackView: UIStackView!
    @IBOutlet weak var coupleStackView: UIStackView!
    
    @IBOutlet weak var name1TextField: UITextField!
    @IBOutlet weak var dob1TextField: UITextField!
    @IBOutlet weak var gender1SegmentedControl: UISegmentedControl!
    @IBOutlet weak var name2TextField: UITextField!
    @IBOutlet weak var dob2TextField: UITextField!
    @IBOutlet weak var gender2SegmentedControl: UISegmentedControl!
    @IBOutlet weak var relationshipStartTextField: UITextField!
    @IBOutlet weak var relationshipSegmentedControl: UISegmentedControl!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var numberOfKidsTextField: UITextField!
    
    var dob1: NSDate? = nil
    var dob2: NSDate? = nil
    var relationshipStart: NSDate? = nil
    var location: CLLocation? = nil
    var children: [Child] = []
    
    var activeTextField: UITextField? = nil
    var datePickerActionSheet: DatePickerActionSheet? = nil
    var genericDatePicker: UIDatePicker? = nil
    var locationPicker: LocationPickerActionSheet? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        
        datePickerActionSheet = DatePickerActionSheet(parent: self, doneActionSelector: "datePickerInputFinished")
        genericDatePicker = datePickerActionSheet!.datePicker
        dob1TextField.inputView = datePickerActionSheet
        dob2TextField.inputView = datePickerActionSheet
        relationshipStartTextField.inputView = datePickerActionSheet
        
        let locationPickerActionSheet = LocationPickerActionSheet(parent: self, doneActionSelector: "locationInputViaZip", locationActionSelector: "locationViaDeviceLocation")
        locationPicker = locationPickerActionSheet
        locationTextField.inputView = locationPicker
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setLocationTextFieldText:", name: "locationUpdated", object: nil)
        
        secondPersonStackView.hidden = true
        coupleStackView.hidden = true
        
        createChildStackViews()
    }
    
    func createChildStackViews() {
        for var i=0; i<25; i++ {
            let childLabel = UILabel()
            childLabel.text = "Child \(i+1)"
            let genderSegmentedControl = UISegmentedControl(items: ["Male", "Female"])
            let dobTextField = UITextField()
            dobTextField.placeholder = "Birthday"
            dobTextField.inputView = datePickerActionSheet
            dobTextField.delegate = self
            let horizontalStackView = UIStackView(arrangedSubviews: [childLabel, genderSegmentedControl, dobTextField])
            horizontalStackView.frame.size.width = coupleStackView.frame.width
            horizontalStackView.distribution = .FillEqually
            horizontalStackView.axis = .Horizontal
            coupleStackView.insertArrangedSubview(horizontalStackView, atIndex: 7+i)
            coupleStackView.subviews.last?.hidden = true
        }
    }
    
    func locationInputViaZip() {
        if let locationPicker = locationPicker {
            if let textField = activeTextField {
                textField.becomeFirstResponder()
                guard let zip = locationPicker.zipTextField.text else {textField.resignFirstResponder(); activeTextField = nil; return}
                LocationController.zipAsCoordinates(zip, completion: { (location) -> Void in
                    if let location = location {
                        self.location = location
                        LocationController.locationAsCityCountry(location, completion: { (cityState) -> Void in
                            if let cityState = cityState {
                                textField.text = cityState
                                textField.resignFirstResponder()
                                self.activeTextField = nil
                            } else {
                                textField.resignFirstResponder()
                                self.activeTextField = nil
                                
                                //TODO: Error handling
                            }
                        })
                    }
                    textField.resignFirstResponder()
                    self.activeTextField = nil
                })
            }
        }
    }
    
    func locationViaDeviceLocation() {
        if let textField = activeTextField {
            textField.becomeFirstResponder()
            if LocationController.resolvePermissions() {
                LocationController.requestLocation()
            } else {
                textField.resignFirstResponder()
                activeTextField = nil
            }
        }
    }
    
    func setLocationTextFieldText(notification: NSNotification) {
        guard let notificationInfo = notification.userInfo else {return}
        if let textField = activeTextField {
            if let location = notificationInfo["location"] as? CLLocation {
                self.location = location
                LocationController.locationAsCityCountry(location, completion: { (cityState) -> Void in
                    if let cityState = cityState {
                        textField.text = cityState
                        textField.resignFirstResponder()
                        self.activeTextField = nil
                    } else {
                        textField.resignFirstResponder()
                        self.activeTextField = nil
                        
                        //TODO: Error handling
                    }
                })
            }
        }
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
                activeTextField = nil
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
            genericDatePicker!.maximumDate = NSDate()
            genericDatePicker!.date = genericDatePicker!.maximumDate!
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
        if textFieldInUse != locationTextField {
            locationTextField.resignFirstResponder()
        }
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
        
        switch state {
        case State.first:
            guard let firstPersonName = name1TextField.text where firstPersonName.characters.count > 0,
                let dob1 = dob1 else {presentAlert("Empty fields", message: "Please fill in all requested information. This will be shown in your profile"); return}
            let age1 = (dob1.timeIntervalSinceNow/(-365)/24/60/60)
            guard age1 > 18 else {presentAlert("Not old enough", message: "Sorry - both partners need to be 18 or older to use this app."); return}
            firstPersonStackView.hidden = true
            secondPersonStackView.hidden = false
            coupleStackView.hidden = true
            state = State.second
        case State.second:
            guard let secondPersonName = name2TextField.text where secondPersonName.characters.count > 0,
                let dob2 = dob2 else {presentAlert("Empty fields", message: "Please fill in all requested information. This will be shown in your profile"); return}
            let age2 = (dob2.timeIntervalSinceNow/(-365)/24/60/60)
            guard age2 > 18 else {presentAlert("Not old enough", message: "Sorry - both partners need to be 18 or older to use this app."); return}
            firstPersonStackView.hidden = true
            secondPersonStackView.hidden = true
            coupleStackView.hidden = false
            state = State.couple
        case State.couple:
            guard let name1 = name1TextField.text where name1.characters.count > 0,
                let name2 = name2TextField.text where name2.characters.count > 0,
                let _ = dob1,
                let _ = dob2,
                let relationshipStart = relationshipStart else {presentAlert("Empty fields", message: "Please fill in all requested information. This will be shown in your profile"); return}
            
            let relationshipLength = relationshipStart.timeIntervalSinceNow/(-365)/24/60/60
            guard relationshipLength > 0 else {presentAlert("Invalid relationship length", message: "Turns out we don't allow relationships that haven't started yet..."); return}
            
            if let numberOfKidsAsText = numberOfKidsTextField.text where numberOfKidsAsText.characters.count > 0 && numberOfKidsAsText != "0" {
                let numberOfKids = Int(numberOfKidsAsText)
                for var i=0; i<numberOfKids; i++ {
                    guard let genderSegmentedControl = coupleStackView.subviews[i+9].subviews[1] as? UISegmentedControl,
                        dobTextField = coupleStackView.subviews[i+9].subviews[2] as? UITextField else {break}
                    guard let dobText = dobTextField.text where dobText.characters.count > 0 else {presentAlert("Missing Information", message: "We use information about your kids to complete your profile, but it isn't required. If you don't want to provide this information please leave the number of children blank or enter \"0\""); return}
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateStyle = .MediumStyle
                    let dob = dateFormatter.dateFromString(dobText)
                    let gender = genderSegmentedControl.selectedSegmentIndex==0 ? "M":"F"
                    let child = Child(dob: dob!, gender: Child.Gender(rawValue: gender)!, profileIdentifier: accountIdentifier!)
                    children.append(child)
                }
            }
            
            self.performSegueWithIdentifier("fromBasicInfoToEditProfile", sender: self)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == numberOfKidsTextField {
            if let numberOfKidsAsText = numberOfKidsTextField.text where numberOfKidsAsText.characters.count > 0 && numberOfKidsAsText != "0" {
                let numberOfKids = Int(numberOfKidsAsText)
                for var i=0; i < 25; i++ {
                    if i<numberOfKids {
                        coupleStackView.subviews[i+9].hidden = false
                    } else {
                        coupleStackView.subviews[i+9].hidden = true
                    }
                }
            } else {
                for var i=0; i < 25; i++ {
                    coupleStackView.subviews[i+9].hidden = true
                }
            }
        }
        name1TextField.resignFirstResponder()
        name2TextField.resignFirstResponder()
        numberOfKidsTextField.resignFirstResponder()
        return true
    }
    
    func reloadView(view: UIView) {
        if view.subviews.count > 0 {
            for var i=0; i<view.subviews.count; i++ {
                reloadView(view.subviews[i])
            }
        }
        view.setNeedsDisplay()
        view.setNeedsLayout()
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromBasicInfoToEditProfile" {
            if let editProfileView = segue.destinationViewController as? EditProfileTableViewController {
                let gender1 = gender1SegmentedControl.selectedSegmentIndex == 0 ? "M":"F"
                let gender2 = gender2SegmentedControl.selectedSegmentIndex == 0 ? "M":"F"
                var person1 = Person(name: name1TextField.text!, dob: dob1!, gender: Person.Gender(rawValue: gender1)!)
                person1.save()
                var person2 = Person(name: name2TextField.text!, dob: dob2!, gender: Person.Gender(rawValue: gender2)!)
                person2.save()
                let relationshipStatusInt = relationshipSegmentedControl.selectedSegmentIndex
                let relationshipStatus = relationshipStatusInt == 0 ? "Dating":(relationshipStatusInt == 1 ? "Engaged":"Married")
                
                editProfileView.people = (person1, person2)
                editProfileView.relationshipStart = relationshipStart!
                editProfileView.relationshipStatus = relationshipStatus
                editProfileView.accountIdentifier = accountIdentifier
                editProfileView.location = location
                editProfileView.children = children.sort({ $0.age > $1.age })
                
            }
        }
    }
    

}
