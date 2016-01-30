//
//  FriendshipTableViewController.swift
//  Double
//
//  Created by James Pacheco on 11/20/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class FriendshipTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    var friendships: [Friendship] {
        
        return FriendshipController.SharedInstance.friendships
    }
    
    @IBOutlet weak var ourProfileView: UIView!
    
    @IBOutlet weak var ourProfileButton: UIButton!
    
    var conversations: [Friendship] {
            return FriendshipController.conversationsForFriendships(friendships)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTableView", name: FriendshipController.kFriendshipsChanged, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadCurrentUserProfileImage", name: "profileImageChanged", object: nil)
        
        layoutNavigationBar()
        
        if let image = ProfileController.SharedInstance.currentUserProfile.image {
            let croppedImage = ImageController.cropImageForCircle(image)
            let resizedImage = ImageController.resizeForCircle(croppedImage)
            self.ourProfileButton.setImage(resizedImage, forState: .Normal)
        } else {
            ProfileController.fetchImageForProfile(ProfileController.SharedInstance.currentUserProfile) { (image) -> Void in
                if let image = image {
                    let croppedImage = ImageController.cropImageForCircle(image)
                    let resizedImage = ImageController.resizeForCircle(croppedImage)
                    self.ourProfileButton.setImage(resizedImage, forState: .Normal)
                }
            }
        }

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
        tabBarController?.tabBar.hidden = false
    }
    
    func layoutNavigationBar() {
        if ourProfileView != nil {
            ourProfileView.layer.cornerRadius = ourProfileView.frame.height / 2
            ourProfileButton.layer.cornerRadius = ourProfileButton.frame.height / 2
        }
        navigationController?.navigationBarHidden = true
    }

    
    func updateTableView() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    func reloadCurrentUserProfileImage() {
        if ourProfileView != nil {
            ImageController.imageForIdentifier(ProfileController.SharedInstance.currentUserProfile.imageEndPoint, completion: { (image) -> Void in
                if let image = image {
                    let croppedImage = ImageController.cropImageForCircle(image)
                    ProfileController.SharedInstance.currentUserProfile.image = image
                    self.ourProfileButton.setImage(croppedImage, forState: .Normal)
                }
            })
        }
    }

    // MARK: - Table view data source
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 95
        } else {
            return 80
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 98
        } else {
            return 80
        }
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return conversations.count
        default:
            return 0
        }
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            if let cell = tableView.dequeueReusableCellWithIdentifier("friendshipCollectionCell", forIndexPath: indexPath) as? FriendshipCollectionCell {
                
                return cell
            }
        case 1:
            if let cell = tableView.dequeueReusableCellWithIdentifier("conversationCell", forIndexPath: indexPath) as? ConversationCell {
                cell.updateWithFriendship(conversations[indexPath.row])
                return cell
            }
        default:
            break
        }
        // If all else fails
        return UITableViewCell()
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Friends"
        case 1:
            return "Conversations"
        default:
            return nil
        }
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        switch (segue.identifier ?? "") {
        case "ConversationListToChat":
            if let chatViewController = segue.destinationViewController as? ChatTableViewController {
                if let indexPath = tableView.indexPathForSelectedRow {
                    if let cell = tableView.cellForRowAtIndexPath(indexPath) as? ConversationCell {
                        chatViewController.profile = cell.profile
                        chatViewController.friendship = conversations[indexPath.row]
                    }
                }
            }
        case "CollectionViewToChat":
            if let chatViewController = segue.destinationViewController as? ChatTableViewController {
                if let collectionCell = sender as? FriendshipCell {
                    chatViewController.friendship = collectionCell.friendship
                    chatViewController.profile = collectionCell.profile
                }
            }
        case "toEditProfile":
            if let editProfileViewController = segue.destinationViewController as? EditProfileTableViewController {
                editProfileViewController.profile = ProfileController.SharedInstance.currentUserProfile
            }
        default:
            break
        }
    }

}
