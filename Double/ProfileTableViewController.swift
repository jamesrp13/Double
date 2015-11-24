//
//  ProfileTableViewController.swift
//  Double
//
//  Created by James Pacheco on 11/20/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    @IBOutlet weak var evaluationStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for var i=0; i<20; i++ {
            ProfileController.createProfile((PersonController.mockPeople()[0], PersonController.mockPeople()[1]), married: (i%2==0 ? true:false), relationshipStart: NSDate(timeIntervalSince1970: 0.0), about: "\(i)", location: "84109", children: nil, image: UIImage(named: "testImage")!) { (profile) -> Void in
                print(profile!.identifier!)
            }
        }

//        ProfileController.fetchUnseenProfiles { (profiles) -> Void in
//            if let profiles = profiles {
//                print(profiles.count)
//                for profile in profiles {
//                    ProfileController.deleteProfile(profile)
//                }
//            }
//
//        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Reject and Like button actions
    
    @IBAction func rejectButtonTapped(sender: AnyObject) {
    }

    @IBAction func likeButtonTapped(sender: AnyObject) {
    }
    
    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return 4
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell: UITableViewCell
        
        switch indexPath.row {
        case 0:
            if let unwrappedCell = self.tableView.dequeueReusableCellWithIdentifier("profileTitleCell", forIndexPath: indexPath) as? ProfileTitleCell {
                unwrappedCell.updateWithProfile(ProfileController.SharedInstance.currentUserProfile)
                cell = unwrappedCell
                
            } else {
                cell = UITableViewCell()
            }
        case 1:
            if let unwrappedCell = tableView.dequeueReusableCellWithIdentifier("profileImageCell", forIndexPath: indexPath) as? ProfileImageCell {
                unwrappedCell.updateWithProfile(ProfileController.SharedInstance.currentUserProfile)
                cell = unwrappedCell
            } else {
                cell = UITableViewCell()
            }
        case 2:
            if let unwrappedCell = tableView.dequeueReusableCellWithIdentifier("profileAboutCoupleCell", forIndexPath: indexPath) as? ProfileAboutCoupleCell {
                unwrappedCell.updateWithProfile(ProfileController.SharedInstance.currentUserProfile)
                cell = unwrappedCell
            } else {
                cell = UITableViewCell()
            }
        case 3:
            if let unwrappedCell = tableView.dequeueReusableCellWithIdentifier("profileAboutIndividualsCell", forIndexPath: indexPath) as? ProfileAboutIndividualsCell {
                unwrappedCell.updateWithProfile(ProfileController.SharedInstance.currentUserProfile)
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
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
