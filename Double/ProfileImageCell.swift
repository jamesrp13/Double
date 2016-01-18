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
        
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    func updateWithProfile(profile: Profile) {
        self.profileImageView.contentMode = .ScaleAspectFill
        self.profileImageView.clipsToBounds = true
        self.profileImageView.layer.borderWidth = 2
        self.profileImageView.layer.borderColor = DesignController.SharedInstance.blueColor.CGColor
        if let image = profile.image {
            self.profileImageView.image = image
        } else {
            ImageController.imageForIdentifier(profile.imageEndPoint) { (image) -> Void in
                self.profileImageView.image = image
//                if let tableView = self.tableView {
//                    tableView.reloadData()
//                }
            }
        }
    }
    
    func updateWithImage(image: UIImage?) {
        self.profileImageView.contentMode = .ScaleAspectFill
        self.profileImageView.image = image
        self.profileImageView.clipsToBounds = true
        self.profileImageView.layer.borderWidth = 2
        self.profileImageView.layer.borderColor = DesignController.SharedInstance.blueColor.CGColor
    }

}
