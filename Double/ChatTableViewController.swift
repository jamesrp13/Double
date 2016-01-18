//
//  ChatTableViewController.swift
//  Double
//
//  Created by James Pacheco on 11/30/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class ChatTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextView: UITextView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bottomStackViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var ourProfileView: UIView!
    @IBOutlet weak var ourProfileButton: UIButton!
   
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
            if tableView != nil {
                tableView.reloadData()
            }
        }
    }
    
    var messages: [Message]? = nil {
        didSet {
            if tableView != nil {
                tableView.reloadData()
            }
        }
    }
    
    var profile: Profile? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutNavigationBar()
        tabBarController?.tabBar.hidden = true
        messageTextView.becomeFirstResponder()
        
        if let image = ProfileController.SharedInstance.currentUserProfile.image {
            let croppedImage = ImageController.cropImageForCircle(image)
            self.ourProfileButton.setImage(croppedImage, forState: .Normal)
        } else {
            ProfileController.fetchImageForProfile(ProfileController.SharedInstance.currentUserProfile) { (image) -> Void in
                if let image = image {
                    let croppedImage = ImageController.cropImageForCircle(image)
                    self.ourProfileButton.setImage(croppedImage, forState: .Normal)
                }
            }
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        tableView.estimatedRowHeight = UITableViewAutomaticDimension
        tableView.rowHeight = UITableViewAutomaticDimension
        titleLabel.text = profile?.coupleTitle ?? ""
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo,
            keyboardSize = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().size {
                bottomStackViewConstraint.constant = keyboardSize.height
        }
    }

    func keyboardWillHide(notification: NSNotification) {
        bottomStackViewConstraint.constant = 0
    }
    
    func layoutNavigationBar() {
        if ourProfileView != nil {
            ourProfileView.layer.cornerRadius = ourProfileView.frame.height / 2
            ourProfileButton.layer.cornerRadius = ourProfileButton.frame.height / 2
        }
        navigationController?.navigationBarHidden = true
        self.view.sendSubviewToBack(tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func sendButtonTapped(sender: AnyObject) {
        guard let text = messageTextView.text, friendship = self.friendship where text.characters.count > 0 else {return}
        
        MessageController.createMessage(friendship, text: text, senderProfileIdentifier: ProfileController.SharedInstance.currentUserProfile!.identifier!)
        
        messageTextView.text = nil
    }
    
    // MARK: - Table view data source

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let messages = messages {
            return messages.count
        } else {
            return 1
        }
    }

    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
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
            if let profileViewController = segue.destinationViewController as? ProfileTableViewController {
                if let profile = self.profile,
                    friendship = self.friendship {
                        profileViewController.profileForViewing = profile
                        profileViewController.fromFriendship = friendship
                }
                
            }
        }
    }

}
