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
            self.profileImageView.contentMode = .ScaleAspectFit
            self.profileImageView.image = image
        }
    }
    
    func updateWithImage(image: UIImage?) {
        self.profileImageView.contentMode = .ScaleAspectFit
        self.profileImageView.image = image
    }

}
