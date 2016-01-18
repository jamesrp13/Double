//
//  ConversationCell.swift
//  Double
//
//  Created by James Pacheco on 11/20/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class ConversationCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var conversationTitleLabel: UILabel!
    @IBOutlet weak var messagePreviewLabel: UILabel!
    
    var profile: Profile? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateWithFriendship(friendship: Friendship) {
        let profileIdentifer = friendship.profileIdentifiers.0 == ProfileController.SharedInstance.currentUserProfile!.identifier! ? friendship.profileIdentifiers.1:friendship.profileIdentifiers.0
        ProfileController.fetchProfileForIdentifier(profileIdentifer) { (profile) -> Void in
            if let profile = profile {
                self.profile = profile
                
                ImageController.imageForIdentifier(profile.imageEndPoint, completion: { (image) -> Void in
                    if let image = image {
                        let croppedImage = ImageController.cropImageForCircle(image)
                        self.profileImageView.image = croppedImage
                    }
                    self.profileImageView.layer.cornerRadius = self.profileImageView.frame.height / 2
                    self.profileImageView.layer.borderWidth = 2
                    self.profileImageView.layer.borderColor = DesignController.SharedInstance.blueColor.CGColor
                    self.profileImageView.clipsToBounds = true
                })
                if let messages = friendship.messages {
                    self.conversationTitleLabel.text = profile.coupleTitle
                    self.messagePreviewLabel.text = messages.last?.text
                    self.messagePreviewLabel.backgroundColor = (messages.last?.identifier ?? "") == ProfileController.SharedInstance.currentUserIdentifier! ? DesignController.SharedInstance.grayBackground:DesignController.SharedInstance.greenColor
                }
            }
        }
    }

}
