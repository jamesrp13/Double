//
//  ChatTableViewController.swift
//  Double
//
//  Created by James Pacheco on 11/30/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class ChatTableViewController: UITableViewController {

    var friendship: Friendship? = nil {
        didSet {
            tableView.reloadData()
        }
    }
    
    var messages: [Message]? {
        if let friendship = friendship {
            return friendship.messages
        } else {
            return nil
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let messages = messages {
            return messages.count
        } else {
            return 1
        }
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if let messages = messages {
            if messages[indexPath.row].profileId == ProfileController.SharedInstance.currentUserProfile.identifier! {
                let cell = tableView.dequeueReusableCellWithIdentifier("ChatRightAlignedTableViewCell") as! ChatRightAlignedTableViewCell
                cell.updateWithMessage(messages[indexPath.row])
                return cell
            } else {
                let cell = tableView.dequeueReusableCellWithIdentifier("ChatLeftAlignedTableViewCell") as! ChatLeftAlignedTableViewCell
                cell.updateWithMessage(messages[indexPath.row])
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCellWithIdentifier("NewChatTableViewCell") as! NewChatTableViewCell
            return cell
        }
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
