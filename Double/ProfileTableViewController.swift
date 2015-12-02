//
//  ProfileTableViewController.swift
//  Double
//
//  Created by James Pacheco on 11/20/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    var profilesBeingViewed: [Profile] {
        return ProfileController.SharedInstance.profilesBeingViewed
    }
    
    var isViewingOwnProfile = false
    
    @IBOutlet weak var evaluationStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTableView", name: "ProfilesChanged", object: nil)
  
//        for var i=0; i<100; i++ {
//            
//            ProfileController.createProfile((PersonController.mockPeople()[0], PersonController.mockPeople()[1]), married: (i%2==0 ? true:false), relationshipStart: NSDate(timeIntervalSince1970: 0.0), about: "\(i)", location: "84109", children: nil, image: UIImage(named: "testImage")!) { (profile) -> Void in
//                
//            }
//        }
//
        
        
//        ProfileController.fetchUnseenProfiles { (profiles) -> Void in
//            if let profiles = profiles {
//                for var i=0; i<profiles.count; i++ {
//                    if i%3==0 {
//                        var response = Responses(profileViewedByIdentifier: profiles[i].identifier!, like: (i%2==0 ? false:true), profileIdentifier: ProfileController.SharedInstance.currentUserProfile.identifier!)
//                        response.save()
//                    }
//                }
//            }
//        }
        
//        var message = Message(friendshipId: "-K49LD03sCBF5aV10q0W", profileId: "-K3vyxVu1d0xOd3SBjB9", text: "Hello. This is a test")
//        message.save()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTableView() {
        tableView.reloadData()
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
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if profilesBeingViewed.count > 0 {
            return 4
        } else {
            return 0
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell
        
        let profile = isViewingOwnProfile ? ProfileController.SharedInstance.currentUserProfile:profilesBeingViewed[0]

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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
