//
//  FriendshipTableViewController.swift
//  Double
//
//  Created by James Pacheco on 11/20/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class FriendshipTableViewController: UITableViewController {

    var friendships: [Friendship] {
        
        return FriendshipController.SharedInstance.friendships
    }
    
    var conversations: [Friendship] {
            return FriendshipController.conversationsForFriendships(friendships)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "updateTableView", name: FriendshipController.kFriendshipsChanged, object: nil)
     
        tableView.estimatedRowHeight = 30
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.setNeedsLayout()
        self.tableView.layoutIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        tableView.reloadData()
    }
    
    func updateTableView() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return conversations.count
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
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
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
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
        case "toOwnProfile":
            if let navigationViewController = segue.destinationViewController as? UINavigationController {
                if let profileViewController = navigationViewController.viewControllers.first as? ProfileTableViewController {
                    profileViewController.profileForViewing = ProfileController.SharedInstance.currentUserProfile
                }
            }
        default:
            break
        }
    }

}
