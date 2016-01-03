//
//  ProfileTableViewController.swift
//  Double
//
//  Created by James Pacheco on 11/20/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit
import CoreLocation


class ProfileTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    @IBOutlet weak var tableView: UITableView!
    
    var profilesBeingViewed: [Profile] {
        return ProfileController.SharedInstance.profilesBeingViewed
    }
    
    @IBOutlet weak var ourProfileView: UIView!
    
    @IBOutlet weak var ourProfileButton: UIButton!
    
    @IBOutlet weak var logoutButton: UIBarButtonItem!
    
    var profileForViewing: Profile? = nil
    var profileForEvaluation: Profile? = nil
    var fromFriendship: Friendship? = nil
    
    @IBOutlet weak var evaluationStackView: UIStackView!
    
    @IBOutlet weak var noMoreProfilesStackView: UIStackView!
    
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
        
        
        tableView.layer.cornerRadius = 10
        tableView.backgroundColor = DesignController.SharedInstance.grayBackground
        if let profile = profileForViewing {
            ProfileController.fetchImageForProfile(profile) { (image) -> Void in
                if let image = image {
                    if self.ourProfileView != nil {
                        self.ourProfileButton.setImage(image, forState: .Normal)
                    }
                }
            }
        } else {
            if let profile = ProfileController.SharedInstance.currentUserProfile {
                ProfileController.fetchImageForProfile(profile) { (image) -> Void in
                    if let image = image {
                        self.ourProfileButton.setImage(image, forState: .Normal)
                    }
                }
            }
        }

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "profilesBeingViewedChanged", name: "profilesBeingViewedChanged", object: nil)
        if profilesBeingViewed.count == 0 {
            updateViewForNoProfiles()
        }
        layoutNavigationBar()
        
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    @IBAction func checkForProfilesButtonTapped(sender: AnyObject) {
        ProfileController.fetchProfileForDisplay()
    }
    
    @IBAction func doneButtonTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func layoutNavigationBar() {
        if ourProfileView != nil {
            ourProfileView.layer.cornerRadius = ourProfileView.frame.height / 2
            ourProfileButton.layer.cornerRadius = ourProfileButton.frame.height / 2
        }
        navigationController?.navigationBarHidden = true
        self.view.sendSubviewToBack(tableView)
    }
    
    func updateTableView() {
        tableView.reloadData()
    }
    
    func profilesBeingViewedChanged() {
        guard profileForViewing == nil else {return}
        if profilesBeingViewed.count == 0 {
            updateViewForNoProfiles()
            updateTableView()
        } else {
            updateViewForMoreProfiles()
            updateTableView()
        }
    }
    
    // MARK: - Reject and Like button actions
    
    @IBAction func rejectButtonTapped(sender: AnyObject) {
        ResponseController.createResponse(profilesBeingViewed[0].identifier!, liked: false) { (responses) -> Void in
            self.removeProfileFromViewingList()
        }
    }
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
        ResponseController.createResponse(profilesBeingViewed[0].identifier!, liked: true) { (responses) -> Void in
            ProfileController.checkForMatch(self.profilesBeingViewed[0].identifier!)
            self.removeProfileFromViewingList()
        }
    }
    
    
    func removeProfileFromViewingList() {
        ProfileController.SharedInstance.profilesBeingViewed.removeFirst()
        tableView.reloadData()
    }
    
    @IBAction func logoutButtonTapped(sender: AnyObject) {
        if let profile = profileForViewing {
            if profile == ProfileController.SharedInstance.currentUserProfile! {
                AccountController.logoutCurrentUser { () -> Void in
                    self.dismissViewControllerAnimated(false, completion: nil)
                    if let tabBarController = UIApplication.sharedApplication().delegate?.window??.rootViewController as? UITabBarController {
                        tabBarController.selectedIndex = 0
                    }
                }
            } else {
                if let friendship = fromFriendship {
                    let otherProfileIdentifier = friendship.profileIdentifiers.0 == ProfileController.SharedInstance.currentUserIdentifier! ? friendship.profileIdentifiers.1:friendship.profileIdentifiers.0
                    FirebaseController.base.childByAppendingPath("responses/\(otherProfileIdentifier)/\(ProfileController.SharedInstance.currentUserIdentifier!)").setValue(false)
                    friendship.delete()
                    self.dismissViewControllerAnimated(false, completion: nil)
                    if let tabBarController = UIApplication.sharedApplication().delegate?.window??.rootViewController as? UITabBarController {
                            tabBarController.selectedIndex = 1
                        if let navigationController = tabBarController.selectedViewController as? UINavigationController {
                            if let friendshipViewController = navigationController.viewControllers[0] as? FriendshipTableViewController {
                                friendshipViewController.tableView.reloadData()
                                navigationController.popToRootViewControllerAnimated(false)
                            }
                        }
                    }
                }
            }
        }
    }
    
    func updateViewForNoProfiles() {
        tableView.hidden = true
        evaluationStackView.hidden = true
        noMoreProfilesStackView.hidden = false
    }
    
    func updateViewForMoreProfiles() {
        tableView.hidden = false
        evaluationStackView.hidden = false
        noMoreProfilesStackView.hidden = true
    }
    
    // MARK: - Table view data source

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if profilesBeingViewed.count > 0 || profileForViewing != nil {
            return 4
        } else {
            return 0
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
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
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 3 {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let viewController = storyboard.instantiateViewControllerWithIdentifier("basicInfoController") as? BasicInfoViewController
            viewController
            
        }
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
                editProfileViewController.profile = ProfileController.SharedInstance.currentUserProfile
            }
        }
    }
    

}
