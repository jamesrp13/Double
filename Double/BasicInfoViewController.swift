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
    
    var state: State = State.first {
        didSet {
            if state == .couple {
                LocationController.resolvePermissions()
            }
        }
    }
    var viewType: basicInfoViewType = .createAccount
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var scrollView: UIScrollView!
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
    @IBOutlet weak var nextButton: UIButton!
    
    var person1: Person? = nil
    var person2: Person? = nil
    var relationshipStart: NSDate? = nil
    var location: CLLocation? = nil
    var children: [Child] = []
    var profile: Profile? = nil
    
    var activeTextField: UITextField? = nil
    var ageDatePicker: UIDatePicker? = nil
    var datePicker: UIDatePicker? = nil
    var toolbar: UIToolbar? = nil
    var locationPicker: LocationPickerActionSheet? = nil
    var numberOfKidsActionSheet: PickerViewActionSheet? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        
        if CLLocationManager.authorizationStatus() == .AuthorizedAlways || CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse {
            LocationController.SharedInstance.locationManager.requestLocation()
        }
        if firstPersonStackView != nil {
            loadProperState()
        }
        setupConstraints()
        createInputView()
        configureInputFields()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    // MARK: - Presentation and input configuration
    
    func setupConstraints() {
        if viewType != .editProfile {
            topConstraint.constant = self.view.frame.height / 6
            bottomConstraint.constant = self.view.frame.height / 5
        }
    }
    
    func createInputView() {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .Date
        datePicker.date = NSDate()
        let ageDatePicker = UIDatePicker()
        ageDatePicker.datePickerMode = .Date
        ageDatePicker.date = NSDate()
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem()
        //doneButton.setTitlePositionAdjustment(UIOffsetMake(0, 0), forBarMetrics: .Default)
        doneButton.title = "Done"
        doneButton.target = self
        doneButton.action = "datePickerDone"
        doneButton.tintColor = DesignController.SharedInstance.blueColor
        let backButton = UIBarButtonItem()
        let forwardButton = UIBarButtonItem()
        backButton.target = self
        backButton.action = "inputBackButtonTapped"
        backButton.image = UIImage(named: "BackButton")
        backButton.tintColor = DesignController.SharedInstance.blueColor
        forwardButton.target = self
        forwardButton.action = "inputForwardButtonTapped"
        forwardButton.image = UIImage(named: "ForwardButton")
        forwardButton.tintColor = DesignController.SharedInstance.blueColor
        let flex = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        toolbar.setItems([flex, doneButton], animated: true)
        //toolbar.frame.size.height = toolbar.frame.height * 0.75
        self.ageDatePicker = ageDatePicker
        self.datePicker = datePicker
        self.toolbar = toolbar
    }
    
    func datePickerDone() {
        if let activeTextField = activeTextField {
            let datePicker = activeTextField.inputView == self.datePicker ? self.datePicker:ageDatePicker
            activeTextField.text = DateController.stringFromDate(datePicker!.date)
            activeTextField.resignFirstResponder()
        }
    }
    
    func inputBackButtonTapped() {
        
    }
    
    func inputForwardButtonTapped() {
        
    }
    
    func configureInputFields() {
        dob1TextField?.inputView = ageDatePicker
        dob1TextField?.inputAccessoryView = toolbar
        dob2TextField?.inputView = ageDatePicker
        dob2TextField?.inputAccessoryView = toolbar
        relationshipStartTextField.inputView = datePicker
        relationshipStartTextField.inputAccessoryView = toolbar
        
        let locationPickerActionSheet = LocationPickerActionSheet(parent: self, useZipSelector: "getLocationFromZip", useLocationSelector: "locationViaDeviceLocation")
        locationPicker = locationPickerActionSheet
        locationTextField.inputView = locationPicker
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
    
    func keyboardWillShow(notification: NSNotification) {
        guard let activeTextField = activeTextField,
            bottomConstraint = bottomConstraint where activeTextField == locationTextField else {return}
        if let userInfo = notification.userInfo,
            keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size {
                let newConstraint = keyboardSize.height - nextButton.frame.height
                
                if newConstraint > bottomConstraint.constant {
                    bottomConstraint.constant = newConstraint
                    mainStackView.layoutIfNeeded()
                    scrollView.scrollRectToVisible(activeTextField.frame, animated: true)
                }
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        guard let activeTextField = activeTextField,
            bottomConstraint = bottomConstraint where activeTextField == locationTextField else {return}
        bottomConstraint.constant = 100
        mainStackView.layoutIfNeeded()
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
    }
    
    func updateWithInfo(people: (Person, Person), relationshipStatus: String, relationshipStart: NSDate, location: CLLocation, children: [Child], accountIdentifier: String) {
        self.person1 = people.0
        self.person2 = people.1
        self.relationshipStart = relationshipStart
        self.location = location
        self.children = children
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .MediumStyle
        
        guard let _ = self.person1,
            _ = self.person2,
            _ = self.relationshipStart,
            _ = self.location else {return}
        
        relationshipStartTextField.text = dateFormatter.stringFromDate(relationshipStart)
        relationshipSegmentedControl.selectedSegmentIndex = relationshipStatus == "Dating" ? 0:(relationshipStatus == "Engaged" ? 1:2)
        LocationController.locationAsCityCountry(location) { (cityState) -> Void in
            if let cityState = cityState {
                self.locationTextField.text = cityState
            }
        }
        
        switch relationshipStatus {
        case "dating":
            relationshipStartLabel.text = "When did you start dating?"
        case "engaged":
            relationshipStartLabel.text = "When did you get engaged?"
        case "married":
            relationshipStartLabel.text = "When did you get married?"
        default:
            relationshipStartLabel.text = "When did you start dating?"
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
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem()
        //doneButton.setTitlePositionAdjustment(UIOffsetMake(0, 0), forBarMetrics: .Default)
        doneButton.title = "Done"
        doneButton.target = self
        doneButton.action = "zipCodeAdded"
        doneButton.tintColor = DesignController.SharedInstance.blueColor
        let flex = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: self, action: nil)
        toolbar.setItems([flex, doneButton], animated: true)
        //toolbar.frame.size.height = toolbar.frame.height * 0.75
        locationTextField.inputAccessoryView = toolbar
        locationTextField.becomeFirstResponder()
    }
    
    func zipCodeAdded() {
        self.locationTextField.resignFirstResponder()
        if let zip = locationTextField.text where zip.characters.count > 4 {
            let loadingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("loadingVC")
            loadingVC.modalPresentationStyle = .OverFullScreen
            presentViewController(loadingVC, animated: false, completion: nil)
            LocationController.zipAsCoordinates(zip, completion: { (location) -> Void in
                if let location = location {
                    self.location = location
                    LocationController.locationAsCityCountry(location, completion: { (cityState) -> Void in
                        self.dismissViewControllerAnimated(false) {
                            if let cityState = cityState {
                                self.locationTextField.text = cityState
                            }
                        }
                    })
                }
            })
        }
    }
    
    func locationViaDeviceLocation() {
        self.locationTextField.resignFirstResponder()
        let loadingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("loadingVC")
        loadingVC.modalPresentationStyle = .OverFullScreen
        presentViewController(loadingVC, animated: false, completion: nil)
        if let location = LocationController.SharedInstance.locationManager.location {
            LocationController.locationAsCityCountry(location, completion: { (cityState) -> Void in
                self.dismissViewControllerAnimated(false) {
                    if let cityState = cityState {
                        self.locationTextField.text = cityState
                    }
                }
            })
            NSNotificationCenter.defaultCenter().removeObserver(self, name: "locationUpdated", object: nil)
            NSNotificationCenter.defaultCenter().removeObserver(self, name: "FailedToFindLocation", object: nil)
        } else {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "setLocationTextFieldText:", name: "locationUpdated", object: nil)
            NSNotificationCenter.defaultCenter().addObserver(self, selector: "tellUserLocationNotFound", name: "FailedToFindLocation", object: nil)
            LocationController.SharedInstance.locationManager.requestLocation()
        }
    }
    
    func tellUserLocationNotFound() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: "FailedToFindLocation", object: nil)
        dismissViewControllerAnimated(false) {
            self.presentAlert("Location not found", message: "Sorry, but it looks like we couldn't get a fix on your location. Try again or enter your zip code.")
        }
    }
    
    func setLocationTextFieldText(notification: NSNotification) {
        guard let notificationInfo = notification.userInfo else {return}
        if let textField = activeTextField {
            if let location = notificationInfo["location"] as? CLLocation {
                self.location = location
                LocationController.locationAsCityCountry(location, completion: { (cityState) -> Void in
                    self.dismissViewControllerAnimated(false, completion: nil)
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
    
    func textFieldDidBeginEditing(textField: UITextField) {
        activeTextField = textField
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
    
    func textFieldShouldBeginEditing(textField: UITextField) -> Bool {
        if textField == locationTextField {
            textField.text = ""
        }
        return true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        name1TextField.resignFirstResponder()
        name2TextField.resignFirstResponder()
        return true
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField == locationTextField {
            locationTextField.inputView = locationPicker
            locationTextField.inputAccessoryView = nil
        }
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
                self.performSegueWithIdentifier("fromBasicInfoToEditProfile", sender: self)
            }
        } else if viewType == .editProfile {
            guard let location = location,
                relationshipStart = DateController.dateFromString(relationshipStartTextField.text ?? "") else {return}
            let relationshipStatusInt = relationshipSegmentedControl.selectedSegmentIndex
            let relationshipStatus = relationshipStatusInt == 0 ? "dating":(relationshipStatusInt == 1 ? "engaged":"married")
            let relationshipLength = relationshipStart.timeIntervalSinceNow/(-365)/24/60/60
            guard relationshipLength > 0 else {presentAlert("Invalid relationship length", message: "Turns out we don't allow relationships that haven't started yet..."); return}
            
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
            } else {
                if let navigationViewController = self.presentingViewController as? UINavigationController {
                    if let presentingViewController = navigationViewController.viewControllers[1] as? EditProfileTableViewController {
                        presentingViewController.relationshipStart = relationshipStart
                        presentingViewController.relationshipStatus = relationshipStatus
                        presentingViewController.location = location
                        presentingViewController.children = children
                        presentingViewController.tableView.reloadData()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    } else if let presentingViewController = navigationViewController.viewControllers[3] as? EditProfileTableViewController {
                        presentingViewController.relationshipStart = relationshipStart
                        presentingViewController.relationshipStatus = relationshipStatus
                        presentingViewController.location = location
                        presentingViewController.children = children
                        presentingViewController.tableView.reloadData()
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                }
            }
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "fromBasicInfoToEditProfile" {
            if let editProfileView = segue.destinationViewController as? EditProfileTableViewController {
                guard var personOne = person1,
                    personTwo = person2,
                    let location = location,
                    let relationshipStart = relationshipStart else {return}
                let relationshipStatusInt = relationshipSegmentedControl.selectedSegmentIndex
                let relationshipStatus = relationshipStatusInt == 0 ? "Dating":(relationshipStatusInt == 1 ? "Engaged":"Married")
                
                personOne.profileIdentifier = accountIdentifier!
                personTwo.profileIdentifier = accountIdentifier!
                editProfileView.people = (personOne, personTwo)
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