//
//  EditProfileTableViewController.swift
//  Double
//
//  Created by James Pacheco on 12/3/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class EditProfileTableViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIPopoverPresentationControllerDelegate {

    var accountIdentifier: String? = nil
    
    var image: UIImage? = nil {
        didSet {
            tableView.reloadData()
        }
    }
    
    var people: (Person, Person)? = nil {
        didSet {
            tableView.reloadData()
        }
    }
    
    var relationshipStatus: String? = nil {
        didSet {
            tableView.reloadData()
        }
    }
    
    var relationshipStart: NSDate? = nil {
        didSet {
            tableView.reloadData()
        }
    }
    
    var location: CLLocation? = nil {
        didSet {
            tableView.reloadData()
        }
    }
    
    var children: [Child] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var profile: Profile? = nil {
        didSet {
            tableView.reloadData()
            if let profile = profile {
                people = profile.people
                relationshipStatus = profile.relationshipStatus.rawValue
                relationshipStart = profile.relationshipStart
                accountIdentifier = profile.identifier!
                location = profile.location
                ImageController.imageForIdentifier(profile.imageEndPoint, completion: { (image) -> Void in
                    if let image = image {
                        self.image = image
                    }
                })
            }
        }
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updatedLocation:", name: "locationUpdated", object: nil)
//        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationFailed", name: "FailedToFindLocation", object: nil)
        
        tableView.estimatedRowHeight = 30
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func imageTapped(sender: AnyObject) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        let alert = UIAlertController(title: "Select Photo Location", message: nil, preferredStyle: .ActionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (_) -> Void in
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }))
        }
        
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (_) -> Void in
                imagePicker.sourceType = .Camera
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }))
        }
        
        imagePicker.allowsEditing = true
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)

    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        let croppedImage = info[UIImagePickerControllerEditedImage] as? UIImage
        self.image = croppedImage
    }
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        guard let image = image else { presentAlert("Please add an image", message: "") ;return }
        guard let profileAboutCoupleCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 2, inSection: 0)) as? ProfileAboutCoupleCell,
            let profileAboutIndividualsCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0)) as? ProfileAboutIndividualsCell else {print("cells didn't cast right"); return}
        guard let people = people,
            accountIdentifier = accountIdentifier,
            relationshipStatus = Profile.RelationshipStatus(rawValue: profileAboutCoupleCell.relationshipStatus!),
            relationshipStart = profileAboutCoupleCell.relationshipStart,
            location = location else {return}
        
        let oldPerson1 = people.0
        let oldPerson2 = people.1
        let newPerson1 = Person(name: oldPerson1.name, dob: oldPerson1.dob, gender: oldPerson1.gender, about: profileAboutIndividualsCell.firstPersonAboutTextView.text, profileIdentifier: accountIdentifier, identifier: oldPerson1.identifier!)
        let newPerson2 = Person(name: oldPerson2.name, dob: oldPerson2.dob, gender: oldPerson2.gender, about: profileAboutIndividualsCell.secondPersonAboutTextView.text, profileIdentifier: accountIdentifier, identifier: oldPerson2.identifier)
        
        ProfileController.createProfile((newPerson1, newPerson2), relationshipStatus: relationshipStatus, relationshipStart: relationshipStart, about: nil, location: location, children: nil, image: image, profileIdentifier: accountIdentifier, completion: { (profile) -> Void in
            if let profile = profile {
                ProfileController.SharedInstance.currentUserProfile = profile
                FirebaseController.loadNecessaryDataFromNetwork()
                self.dismissViewControllerAnimated(true, completion: { () -> Void in
                    NSNotificationCenter.defaultCenter().postNotificationName("profileEdited", object: self)
                })
            } else {
                print("profile not created")
            }
        })
        
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        
        switch indexPath.row {
        case 0:
            if let unwrappedCell = self.tableView.dequeueReusableCellWithIdentifier("profileTitleCell", forIndexPath: indexPath) as? ProfileTitleCell {
                //unwrappedCell.updateWithProfile(profile)
                if let profile = profile {
                    unwrappedCell.updateWithProfile(profile)
                } else {
                    if let people = people {
                        unwrappedCell.titleLabel.text = "\(people.0.name) and \(people.1.name)"
                    } else {
                        print("It doesn't look like there are any people in this profile...")
                    }
                }
                cell = unwrappedCell
            } else {
                cell = UITableViewCell()
            }
        case 1:
            if let unwrappedCell = tableView.dequeueReusableCellWithIdentifier("profileImageCell", forIndexPath: indexPath) as? ProfileImageCell {
                if let image = image {
                    unwrappedCell.updateWithImage(image)
                } else if let profile = profile {
                    unwrappedCell.updateWithProfile(profile)
                } else {
                    print("It doesn't look like we have an image...")
                }
                cell = unwrappedCell
                
            } else {
                cell = UITableViewCell()
            }
        case 2:
            if let unwrappedCell = tableView.dequeueReusableCellWithIdentifier("profileAboutCoupleCell", forIndexPath: indexPath) as? ProfileAboutCoupleCell {
                unwrappedCell.parentTableViewController = self
                if let profile = profile {
                    unwrappedCell.updateWithProfile(profile)
                } else {
                    if let people = people {
                        if let relationshipStart = relationshipStart,
                            relationshipStatus = relationshipStatus,
                            location = location {
                                unwrappedCell.updateWithPeople(people, relationshipStatus: "\(relationshipStatus)", relationshipStart: relationshipStart, children: children, location: location)
                        }
                        
                    } else {
                        print("It doesn't look like there are any people in this profile")
                    }
                }
                
                cell = unwrappedCell
            } else {
                cell = UITableViewCell()
            }
        case 3:
            if let unwrappedCell = tableView.dequeueReusableCellWithIdentifier("profileAboutIndividualsCell", forIndexPath: indexPath) as? ProfileAboutIndividualsCell {
                if let profile = profile {
                    unwrappedCell.updateWithProfile(profile)
                } else {
                    if let people = people {
                        unwrappedCell.updateWithPeople(people)
                    }
                }
                cell = unwrappedCell
            } else {
                cell = UITableViewCell()
            }
            
        default:
            cell = UITableViewCell()
            return cell
            
        }
        
        return cell

    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func displayBasicInfoPopoverViewController() {
        if let indexPath = tableView.indexPathForSelectedRow {
            tableView.cellForRowAtIndexPath(indexPath)?.selected = false
        }
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            let basicInfoViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("basicInfoController") as! BasicInfoViewController
            basicInfoViewController.modalPresentationStyle = .Popover
            basicInfoViewController.preferredContentSize = CGSizeMake(self.view.frame.width-20, self.view.frame.height-100)
            
            let popoverBasicinfoController = basicInfoViewController.popoverPresentationController
            popoverBasicinfoController?.delegate = self
            popoverBasicinfoController?.permittedArrowDirections = .Down
            popoverBasicinfoController?.sourceView = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0))!
            popoverBasicinfoController?.sourceRect = self.tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 3, inSection: 0))!.bounds
            
            self.presentViewController(basicInfoViewController, animated: true) { () -> Void in
                if let profile = self.profile {
                    basicInfoViewController.updateWithProfile(profile)
                }
            }
        }
    }
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
}
