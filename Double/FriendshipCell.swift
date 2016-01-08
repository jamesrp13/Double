//
//  FriendshipCell.swift
//  Double
//
//  Created by James Pacheco on 11/21/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class FriendshipCell: UICollectionViewCell {
    
    @IBOutlet weak var coupleTitleLabel: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    var friendship: Friendship? = nil
    var profile: Profile? = nil
 
    func updateWithFriendship(friendship: Friendship) {
        self.friendship = friendship
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
                self.coupleTitleLabel.text = profile.coupleTitle
            }
        }
    }
}
