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
    
    var seenDictionary: [String: Int] {
        
        if let seenDictionary = NSUserDefaults.standardUserDefaults().objectForKey("seenDictionary") as? [String: Int] {
            return seenDictionary
        } else {
            return [:]
        }
    }
    
    @IBOutlet weak var evaluationStackView: UIStackView!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        if ProfileController.SharedInstance.currentUserProfile == nil {
            performSegueWithIdentifier("toLoginSignup", sender: self)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTableView", name: "ProfilesChanged", object: nil)
        
        tableView.estimatedRowHeight = 30
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
        
//        for (key, value) in seenDictionary {
//            print("\(key): \(value)")
//        }
        
//        var seenDictionary: [String: Int] = [:]
//        
//        for var i=0; i<100; i++ {
//            
//            ProfileController.createProfile((PersonController.mockPeople()[0], PersonController.mockPeople()[1]), married: (i%2==0 ? true:false), relationshipStart: NSDate(timeIntervalSince1970: 0.0), about: "\(i)", location: "84109", children: nil, image: UIImage(named: "testImage")!) { (profile) -> Void in
//                if let profile = profile {
//                    seenDictionary.updateValue(0, forKey: profile.identifier!)
//                    if i%3==0 {
//                        var response = Responses(profileViewedByIdentifier: profile.identifier!, like: (i%2==0 ? false:true), profileIdentifier: ProfileController.SharedInstance.currentUserProfile.identifier!)
//                        response.save()
//                    }
//
//                }
//            }
//        }
//
//        NSUserDefaults.standardUserDefaults().setObject(seenDictionary, forKey: "seenDictionary")
//        NSUserDefaults.standardUserDefaults().synchronize()
        
//        AccountController.createAccount("jamesrp13@gmail.com", password: "password1", passwordRetyped: "password1") { (account) -> Void in
//            if let account = account {
//                print(account)
//            }
//        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func updateTableView() {
        tableView.reloadData()
        //likeButtonTapped(self)
    }

    // MARK: - Reject and Like button actions
    
    @IBAction func rejectButtonTapped(sender: AnyObject) {
        ResponseController.createResponse(profilesBeingViewed[0].identifier!, liked: false) { (responses) -> Void in
            self.addViewToList()
            self.removeProfileFromViewingList()
        }
    }

    @IBAction func likeButtonTapped(sender: AnyObject) {
        ResponseController.createResponse(profilesBeingViewed[0].identifier!, liked: true) { (responses) -> Void in
            ProfileController.checkForMatch(self.profilesBeingViewed[0].identifier!)
            self.addViewToList()
            self.removeProfileFromViewingList()
        }
    }
    
    func addViewToList() {
        var newSeenDictionary = seenDictionary
        if let value = seenDictionary[profilesBeingViewed[0].identifier!] {
            if value == 1 {
                print("\rLooks like \(profilesBeingViewed[0].identifier!) was seen twice \r")
            }
            newSeenDictionary.updateValue(value + 1, forKey: profilesBeingViewed[0].identifier!)
        }
        
        NSUserDefaults.standardUserDefaults().setObject(newSeenDictionary, forKey: "seenDictionary")
        NSUserDefaults.standardUserDefaults().synchronize()
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
        
        if let profile = isViewingOwnProfile ? ProfileController.SharedInstance.currentUserProfile:profilesBeingViewed[0] {
            
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
