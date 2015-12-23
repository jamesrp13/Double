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
    
    enum basicInfoViewType {
        case createAccount
        case editProfile
    }
    
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
    var viewType: basicInfoViewType = .createAccount
    
    @IBOutlet weak var firstPersonStackView: UIStackView!
    @IBOutlet weak var secondPersonStackView: UIStackView!
    @IBOutlet weak var coupleStackView: UIStackView!
    @IBOutlet weak var coupleParentStackView: UIStackView!
    @IBOutlet weak var mainStackView: UIStackView!
    
    @IBOutlet weak var relationshipStartLabel: UILabel!
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
    @IBOutlet weak var nextButton: UIButton!
    
    var person1: Person? = nil
    var person2: Person? = nil
    var relationshipStart: NSDate? = nil
    var location: CLLocation? = nil
    var children: [Child] = []
    var profile: Profile? = nil
    
    var activeTextField: UITextField? = nil
    var datePickerActionSheet: DatePickerActionSheet? = nil
    var genericDatePicker: UIDatePicker? = nil
    var locationPicker: LocationPickerActionSheet? = nil
    var numberOfKidsActionSheet: PickerViewActionSheet? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "setLocationTextFieldText:", name: "locationUpdated", object: nil)
        if firstPersonStackView != nil {
            loadProperState()
        }
        setupConstraints()
        configureInputFields()
        createChildStackViews()
    }
    
    // MARK: - Presentation and input configuration
    
    func setupConstraints() {
        let topConstraint = NSLayoutConstraint(item: mainStackView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: self.view.frame.height / 6)
        let bottomConstraint = NSLayoutConstraint(item: mainStackView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: -self.view.frame.height / 5)
        
        self.view.addConstraint(topConstraint)
        self.view.addConstraint(bottomConstraint)
    }
    
    func configureInputFields() {
        datePickerActionSheet = DatePickerActionSheet(parent: self, doneActionSelector: "datePickerInputFinished")
        genericDatePicker = datePickerActionSheet!.datePicker
        if dob1TextField != nil &&
            dob2TextField != nil {
                dob1TextField.inputView = datePickerActionSheet
                dob2TextField.inputView = datePickerActionSheet
        }
        relationshipStartTextField.inputView = datePickerActionSheet
        
        let locationPickerActionSheet = LocationPickerActionSheet(parent: self, useZipSelector: "getLocationFromZip", useLocationSelector: "locationViaDeviceLocation")
        locationPicker = locationPickerActionSheet
        locationTextField.inputView = locationPicker
        
        numberOfKidsActionSheet = PickerViewActionSheet(parent: self, doneActionSelector: "numberOfKidsInputDone")
        numberOfKidsTextField.inputView = numberOfKidsActionSheet
    }
    
    func loadProperState() {
        switch state {
        case .first:
            firstPersonStackView.hidden = false
            secondPersonStackView.hidden = true
            coupleParentStackView.hidden = true
        case .second:
            firstPersonStackView.hidden = true
            secondPersonStackView.hidden = false
            coupleParentStackView.hidden = true
        case .couple:
            firstPersonStackView.hidden = true
            secondPersonStackView.hidden = true
            coupleParentStackView.hidden = false
            nextButton.setTitle("Save", forState: .Normal)
        }
    }
    
    func createChildStackViews() {
        for var i=0; i<25; i++ {
            let childLabel = UILabel()
            childLabel.text = "    Child \(i+1):"
            let font = UIFont(name: "HelveticaNeue-Thin", size: 18)
            childLabel.font = font
            childLabel.textColor = .whiteColor()
            let genderSegmentedControl = UISegmentedControl(items: ["Male", "Female"])
            genderSegmentedControl.selectedSegmentIndex = 0
            genderSegmentedControl.frame.size.width = relationshipSegmentedControl.frame.width * (2.0/3.0)
            let dobTextField = UITextField()
            dobTextField.placeholder = "Birthday"
            dobTextField.font = font
            dobTextField.textColor = .whiteColor()
            dobTextField.inputView = datePickerActionSheet
            dobTextField.delegate = self
            dobTextField.layer.cornerRadius = relationshipStartTextField.layer.cornerRadius
            dobTextField.backgroundColor = relationshipStartTextField.backgroundColor
            let verticalStackView = UIStackView(arrangedSubviews: [genderSegmentedControl, dobTextField])
            verticalStackView.frame.size.width = relationshipSegmentedControl.frame.width * (2.0/3.0)
            verticalStackView.distribution = .FillEqually
            verticalStackView.alignment = .Fill
            verticalStackView.spacing = 5
            verticalStackView.axis = .Vertical
            let horizontalStackView = UIStackView(arrangedSubviews: [childLabel, verticalStackView])
            horizontalStackView.frame.size.width = coupleStackView.frame.width
            horizontalStackView.distribution = .FillProportionally
            horizontalStackView.spacing = 5
            horizontalStackView.axis = .Horizontal
            coupleStackView.insertArrangedSubview(horizontalStackView, atIndex: 6+i)
            coupleStackView.subviews.last?.hidden = true
        }
    }
    
    func updateWithProfile(profile: Profile) {
        state = .couple
        viewType = .editProfile
        self.profile = profile
        person1 = profile.people.0
        person2 = profile.people.1
        relationshipStart = profile.relationshipStart
        location = profile.location
        children = profile.children ?? []
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        
        guard let _ = person1,
            _ = person2,
            relationshipStart = relationshipStart,
            location = location else {return}
        
        relationshipStartTextField.text = dateFormatter.stringFromDate(relationshipStart)
        relationshipSegmentedControl.selectedSegmentIndex = profile.relationshipStatus.rawValue == "Dating" ? 0:(profile.relationshipStatus.rawValue == "Engaged" ? 1:2)
        LocationController.locationAsCityCountry(location) { (cityState) -> Void in
            if let cityState = cityState {
                self.locationTextField.text = cityState
            }
        }
        
        switch profile.relationshipStatus {
        case .Dating:
            relationshipStartLabel.text = "When did you start dating?"
        case .Engaged:
            relationshipStartLabel.text = "When did you get engaged?"
        case .Married:
            relationshipStartLabel.text = "When did you get married?"
        }
        
        if children.count > 0 {
            numberOfKidsTextField.text = "\(children.count)"
            for var i=0; i<children.count; i++ {
                let child = children[i]
                let stackView = coupleStackView.subviews[i+8]
                stackView.hidden = false
                if let genderSegment = stackView.subviews[1] as? UISegmentedControl,
                    dobTextField = stackView.subviews[2] as? UITextField {
                        genderSegment.selectedSegmentIndex = child.gender.rawValue == "M" ? 0:1
                        dobTextField.text = dateFormatter.stringFromDate(child.dob)
                }
            }
        }
    }
    
    @IBAction func segmentedControlTapped(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            relationshipStartLabel.text = "When did you start dating?"
        case 1:
            relationshipStartLabel.text = "When did you get engaged?"
        case 2:
            relationshipStartLabel.text = "When did you get married?"
        default:
            break
        }
    }
    
    // MARK: - Location input handling
    
    func getLocationFromZip() {
        locationTextField.placeholder = "Enter zip code"
        locationTextField.resignFirstResponder()
        locationTextField.inputView = nil
        locationTextField.keyboardType = .NumberPad
        
        let doneButton = UIBarButtonItem()
        doneButton.title = "Done"
        doneButton.action = "zipCodeAdded"
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.frame.size.height = 30.0
        toolbar.items = [doneButton]
        locationTextField.inputAccessoryView = toolbar
        locationTextField.becomeFirstResponder()
    }
    
    func zipCodeAdded() {
        if let zip = locationTextField.text where zip.characters.count > 4 {
            LocationController.zipAsCoordinates(zip, completion: { (location) -> Void in
                if let location = location {
                    self.location = location
                    LocationController.locationAsCityCountry(location, completion: { (cityState) -> Void in
                        if let cityState = cityState {
                            self.locationTextField.text = cityState
                        }
                    })
                }
            })
        }
        locationTextField.resignFirstResponder()
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
    
    // MARK: - Handling input fields
    
    func numberOfKidsInputDone() {
        if let textField = activeTextField {
            if let numberOfKidsPicker = numberOfKidsActionSheet?.pickerView {
                textField.text = String(numberOfKidsPicker.selectedRowInComponent(0))
                if let numberOfKidsAsText = numberOfKidsTextField.text where numberOfKidsAsText.characters.count > 0 && numberOfKidsAsText != "0" {
                    let numberOfKids = Int(numberOfKidsAsText)
                    for var i=0; i < 25; i++ {
                        if i<numberOfKids {
                            coupleStackView.subviews[i+8].hidden = false
                        } else {
                            coupleStackView.subviews[i+8].hidden = true
                        }
                    }
                } else {
                    for var i=0; i < 25; i++ {
                        coupleStackView.subviews[i+8].hidden = true
                    }
                }
                
            }
            textField.resignFirstResponder()
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
    
    func resignFirstResponderForOtherTextFields(textFieldInUse: UITextField?) {
        findTextFields(self.view) { (textFields) -> Void in
            if let textFieldInUse = textFieldInUse {
                for textField in textFields {
                    if textField != textFieldInUse {
                        textField.resignFirstResponder()
                    }
                }
            } else {
                for textField in textFields {
                    textField.resignFirstResponder()
                }
            }
        }
    }
    
    func findTextFields(view: UIView, completion: (textFields: [UITextField]) -> Void) {
        var textFieldArray: [UITextField] = []
        let tunnel = dispatch_group_create()
        for var i=0; i<view.subviews.count; i++ {
            dispatch_group_enter(tunnel)
            findTextFields(view.subviews[i], completion: { (textFields) -> Void in
                textFieldArray += textFields
                dispatch_group_leave(tunnel)
            })
        }
        if let view = view as? UITextField {
            textFieldArray.append(view)
        }
        dispatch_group_notify(tunnel, dispatch_get_main_queue()) { () -> Void in
            completion(textFields: textFieldArray)
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == numberOfKidsTextField {
            if let numberOfKidsAsText = numberOfKidsTextField.text where numberOfKidsAsText.characters.count > 0 && numberOfKidsAsText != "0" {
                let numberOfKids = Int(numberOfKidsAsText)
                for var i=0; i < 25; i++ {
                    if i<numberOfKids {
                        coupleStackView.subviews[i+8].hidden = false
                    } else {
                        coupleStackView.subviews[i+8].hidden = true
                    }
                }
            } else {
                for var i=0; i < 25; i++ {
                    coupleStackView.subviews[i+8].hidden = true
                }
            }
        }
        name1TextField.resignFirstResponder()
        name2TextField.resignFirstResponder()
        numberOfKidsTextField.resignFirstResponder()
        return true
    }
    
    // MARK: - Navigation
    
    @IBAction func nextButtonTapped(sender: AnyObject) {
        
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        if viewType == .createAccount {
            switch state {
            case State.first:
                guard let firstPersonName = name1TextField.text where firstPersonName.characters.count > 0,
                    let dobAsText = dob1TextField.text where dobAsText.characters.count > 0 else {presentAlert("Empty fields", message: "Please fill in all requested information. This will be shown in your profile"); return}
                let dob = dateFormatter.dateFromString(dobAsText)!
                guard PersonController.ageInYearsFromBirthday(dob) >= 18 else {presentAlert("Not old enough", message: "Sorry - both partners need to be 18 or older to use this app."); return}
                let gender = gender1SegmentedControl.selectedSegmentIndex == 0 ? "M":"F"
                let person = Person(name: firstPersonName, dob: dob, gender: Person.Gender(rawValue: gender)!)
                person1 = person
                state = State.second
                loadProperState()
            case State.second:
                guard let secondPersonName = name2TextField.text where secondPersonName.characters.count > 0,
                    let dobAsText = dob2TextField.text where dobAsText.characters.count > 0 else {presentAlert("Empty fields", message: "Please fill in all requested information. This will be shown in your profile"); return}
                let dob = dateFormatter.dateFromString(dobAsText)!
                guard PersonController.ageInYearsFromBirthday(dob) >= 18 else {presentAlert("Not old enough", message: "Sorry - both partners need to be 18 or older to use this app."); return}
                let gender = gender2SegmentedControl.selectedSegmentIndex == 0 ? "M":"F"
                let person = Person(name: secondPersonName, dob: dob, gender: Person.Gender(rawValue: gender)!)
                person2 = person
                state = State.couple
                loadProperState()
            case State.couple:
                guard let _ = person1,
                    _ = person2,
                    relationshipStartAsText = relationshipStartTextField.text where relationshipStartAsText.characters.count > 0 else {presentAlert("Empty fields", message: "Please fill in all required information. This will be shown in your profile"); return}
                guard let _ = location else {presentAlert("Invalid location", message:  "Please give us a valid location or the app just won't work for you.");return}
                relationshipStart = dateFormatter.dateFromString(relationshipStartAsText)!
                let relationshipLength = relationshipStart!.timeIntervalSinceNow/(-365)/24/60/60
                guard relationshipLength > 0 else {presentAlert("Invalid relationship length", message: "Turns out we don't allow relationships that haven't started yet..."); return}
                
                let numberOfKids = Int(numberOfKidsTextField.text!) ?? 0
                for var i=0; i<numberOfKids; i++ {
                    guard let genderSegmentedControl = coupleStackView.subviews[i+8].subviews[1] as? UISegmentedControl,
                        dobTextField = coupleStackView.subviews[i+8].subviews[2] as? UITextField else {break}
                    guard let dobText = dobTextField.text where dobText.characters.count > 0 else {presentAlert("Missing Information", message: "We use information about your kids to complete your profile, but it isn't required. If you don't want to provide this information please leave the number of children blank or enter \"0\""); return}
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateStyle = .MediumStyle
                    let dob = dateFormatter.dateFromString(dobText)
                    let gender = genderSegmentedControl.selectedSegmentIndex==0 ? "M":"F"
                    let child = Child(dob: dob!, gender: Child.Gender(rawValue: gender)!, profileIdentifier: accountIdentifier!)
                    children.append(child)
                }
                self.performSegueWithIdentifier("fromBasicInfoToEditProfile", sender: self)
            }
        } else if viewType == .editProfile {
            guard let _ = person1,
                _ = person2,
                location = location,
                relationshipStart = relationshipStart else {return}
            let relationshipStatusInt = relationshipSegmentedControl.selectedSegmentIndex
            let relationshipStatus = relationshipStatusInt == 0 ? "dating":(relationshipStatusInt == 1 ? "engaged":"married")
            
            if var profile = profile {
                profile.location = location
                profile.relationshipStart = relationshipStart
                profile.relationshipStatus = Profile.RelationshipStatus(rawValue: relationshipStatus)!
                if children.count > 0 {
                    profile.children = children
                }
                ProfileController.SharedInstance.currentUserProfile = profile
                if let editProfileViewController = self.presentingViewController as? EditProfileTableViewController {
                    editProfileViewController.profile = profile
                    editProfileViewController.tableView.reloadData()
                    self.dismissViewControllerAnimated(true, completion: nil)
                }
            }
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromBasicInfoToEditProfile" {
            if let editProfileView = segue.destinationViewController as? EditProfileTableViewController {
                guard var person1 = person1,
                    person2 = person2,
                    let location = location,
                    let relationshipStart = relationshipStart else {return}
                let relationshipStatusInt = relationshipSegmentedControl.selectedSegmentIndex
                let relationshipStatus = relationshipStatusInt == 0 ? "Dating":(relationshipStatusInt == 1 ? "Engaged":"Married")
                
                person1.save()
                person2.save()
                editProfileView.people = (person1, person2)
                editProfileView.relationshipStart = relationshipStart
                editProfileView.relationshipStatus = relationshipStatus
                editProfileView.accountIdentifier = accountIdentifier
                editProfileView.location = location
                editProfileView.children = children.sort({ $0.age > $1.age })
            }
        }
    }
    
    // MARK: - Miscellaneous
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }

}
