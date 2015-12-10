//
//  ProfileTableViewController.swift
//  Double
//
//  Created by James Pacheco on 11/20/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit
import CoreLocation


class ProfileTableViewController: UITableViewController {

    var profilesBeingViewed: [Profile] {
        return ProfileController.SharedInstance.profilesBeingViewed
    }
    
    @IBOutlet weak var ourProfileButton: UIBarButtonItem!
    
    var profileForViewing: Profile? = nil
    
    @IBOutlet weak var evaluationStackView: UIStackView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if ProfileController.SharedInstance.currentUserProfile == nil && ProfileController.SharedInstance.currentUserIdentifier == nil {
            tabBarController?.performSegueWithIdentifier("toLoginSignup", sender: self)
        } else if ProfileController.SharedInstance.currentUserProfile == nil && ProfileController.SharedInstance.currentUserIdentifier != nil {
            tabBarController?.performSegueWithIdentifier("toBasicInfo", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if LocationController.resolvePermissions() {
            LocationController.requestLocation()
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "locationUpdated:", name: "locationUpdated", object: nil)
        
        if let profile = profileForViewing {
            if profile.identifier! == ProfileController.SharedInstance.currentUserIdentifier! {
                ourProfileButton.title = "Edit Profile"
            } else {
                ourProfileButton.enabled = false
            }
        }
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateProfileForViewing", name: "profileEdited", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTableView", name: "ProfilesChanged", object: nil)
        
        tableView.estimatedRowHeight = 30
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
    }
    
    func locationUpdated(notification: NSNotification) {
        if let location = notification.userInfo!["location"] as? CLLocation {
//            FirebaseController.base.childByAppendingPath("responses").queryOrderedByChild("testIdentifier").queryLimitedToFirst(10).queryEndingAtValue(nil).observeSingleEventOfType(.Value, withBlock: { (data) -> Void in
//                if let responseDictionaries = data.value as? [String: AnyObject] {
//                    let profileIdentifiers = responseDictionaries.flatMap({$0.0})
//                    for profileIdentifier in profileIdentifiers {
                        let geoFire = GeoFire(firebaseRef: FirebaseController.base.childByAppendingPath("responses"))
                        geoFire.queryAtLocation(location, withRadius: 40).observeEventType(GFEventTypeKeyEntered, withBlock: { (string, location) -> Void in
                            print(string)
                        })
//                    }
//                }
//            })
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateTableView() {
        tableView.reloadData()
        //likeButtonTapped(self)
    }
    
    func updateProfileForViewing() {
        if let _ = profileForViewing {
            self.profileForViewing = ProfileController.SharedInstance.currentUserProfile
            updateTableView()
        }
    }

    // MARK: - Reject and Like button actions
    
    @IBAction func rejectButtonTapped(sender: AnyObject) {
        ResponseController.createResponse(profilesBeingViewed[0].identifier!, liked: false) { (responses) -> Void in
//            self.addViewToList()
            self.removeProfileFromViewingList()
        }
    }

    @IBAction func likeButtonTapped(sender: AnyObject) {
        ResponseController.createResponse(profilesBeingViewed[0].identifier!, liked: true) { (responses) -> Void in
            ProfileController.checkForMatch(self.profilesBeingViewed[0].identifier!)
//            self.addViewToList()
            self.removeProfileFromViewingList()
        }
    }
    
//    func addViewToList() {
//        var newSeenDictionary = seenDictionary
//        if let value = seenDictionary[profilesBeingViewed[0].identifier!] {
//            if value == 1 {
//                print("\rLooks like \(profilesBeingViewed[0].identifier!) was seen twice \r")
//            }
//            newSeenDictionary.updateValue(value + 1, forKey: profilesBeingViewed[0].identifier!)
//        }
//        
//        NSUserDefaults.standardUserDefaults().setObject(newSeenDictionary, forKey: "seenDictionary")
//        NSUserDefaults.standardUserDefaults().synchronize()
//    }
    
    func removeProfileFromViewingList() {
        ProfileController.SharedInstance.profilesBeingViewed.removeFirst()
        tableView.reloadData()
    }
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        AccountController.logoutCurrentUser { () -> Void in
            self.dismissViewControllerAnimated(false, completion: nil)
            self.tabBarController?.selectedViewController = self.tabBarController?.viewControllers?.first
        }
    }
    
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if profilesBeingViewed.count > 0 || profileForViewing != nil {
            return 4
        } else {
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell
        
        if let profile = profileForViewing != nil ? profileForViewing:profilesBeingViewed[0] {
            
            switch indexPath.row {
            case 0:
                if let unwrappedCell = self.tableView.dequeueReusableCellWithIdentifier("profileTitleCell", forIndexPath: indexPath) as? ProfileTitleCell {
                    unwrappedCell.updateWithProfile(profile)
                    cell = unwrappedCell
                    
                } else {
                    cell = UITableViewCell()
                }
            case 1:
                if let unwrappedCell = tableView.dequeueReusableCellWithIdentifier("profileImageCell", forIndexPath: indexPath) as? ProfileImageCell {
                    unwrappedCell.updateWithProfile(profile)
                    cell = unwrappedCell
                } else {
                    cell = UITableViewCell()
                }
            case 2:
                if let unwrappedCell = tableView.dequeueReusableCellWithIdentifier("profileAboutCoupleCell", forIndexPath: indexPath) as? ProfileAboutCoupleCell {
                    unwrappedCell.updateWithProfile(profile)
                    cell = unwrappedCell
                } else {
                    cell = UITableViewCell()
                }
            case 3:
                if let unwrappedCell = tableView.dequeueReusableCellWithIdentifier("profileAboutIndividualsCell", forIndexPath: indexPath) as? ProfileAboutIndividualsCell {
                    unwrappedCell.updateWithProfile(profile)
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
        return UITableViewCell()

    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toOurProfile" {
            if let navigationController = segue.destinationViewController as? UINavigationController {
                if let profileViewController = navigationController.viewControllers.first as? ProfileTableViewController {
                    profileViewController.profileForViewing = ProfileController.SharedInstance.currentUserProfile
                }
            }
        } else if segue.identifier == "toEditProfile" {
            if let editProfileViewController = segue.destinationViewController as? EditProfileTableViewController {
                editProfileViewController.profile = self.profileForViewing
            }
        }
    }
    

}
