//
//  ProfileImageCell.swift
//  Double
//
//  Created by James Pacheco on 11/20/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class ProfileImageCell: UITableViewCell {

    @IBOutlet weak var profileImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateWithProfile(profile: Profile) {
        ImageController.imageForIdentifier(profile.imageEndPoint) { (image) -> Void in
            self.profileImageView.contentMode = .ScaleAspectFill
            self.profileImageView.image = image
            self.profileImageView.clipsToBounds = true
            self.profileImageView.layer.borderWidth = 2
            self.profileImageView.layer.borderColor = DesignController.SharedInstance.blueColor.CGColor
            self.profileImageView.frame.size.width = self.frame.width - 80
            self.profileImageView.frame.size.height = self.profileImageView.frame.width
        }
    }
    
    func updateWithImage(image: UIImage?) {
        self.profileImageView.contentMode = .ScaleAspectFill
        self.profileImageView.image = image
        self.profileImageView.clipsToBounds = true
        self.profileImageView.layer.borderWidth = 2
        self.profileImageView.layer.borderColor = DesignController.SharedInstance.blueColor.CGColor
        self.profileImageView.frame.size.width = self.frame.width - 80
        self.profileImageView.frame.size.height = self.profileImageView.frame.width
    }

}
