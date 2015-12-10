//
//  ChatTableViewController.swift
//  Double
//
//  Created by James Pacheco on 11/30/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class ChatTableViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var messageTextField: UITextField!
    
    var friendship: Friendship? = nil {
        didSet {
            messages = friendship?.messages
            if let friendship = friendship {
                MessageController.observeLastMessageForFriendshipIdentifier(friendship.identifier!) { (message) -> Void in
                    if let message = message {
                        if var messages = self.messages {
                            if messages.last!.identifier! != message.identifier! {
                                messages.append(message)
                                self.messages = messages
                            }
                        } else {
                            self.messages = [message]
                        }
                    }
                }
            }
            tableView.reloadData()
        }
    }
    
    var messages: [Message]? = nil {
        didSet {
            tableView.reloadData()
        }
    }
    
    var profile: Profile? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        guard let text = messageTextField.text, friendship = self.friendship where text.characters.count > 0 else {return}
        
        MessageController.createMessage(friendship, text: text, senderProfileIdentifier: ProfileController.SharedInstance.currentUserProfile!.identifier!)
        
        messageTextField.text = nil
        messageTextField.resignFirstResponder()
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        sendButtonTapped(self)
        return true
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
            if messages[indexPath.row].profileId == ProfileController.SharedInstance.currentUserProfile!.identifier! {
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

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toFriendsProfile" {
            if let navigationController = segue.destinationViewController as? UINavigationController {
                if let profileViewController = navigationController.viewControllers.first as? ProfileTableViewController {
                    if let profile = self.profile {
                        profileViewController.profileForViewing = profile
                        
                    }
                }
            }
        }
    }

}
