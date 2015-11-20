//
//  ProfileViewController.swift
//  Double
//
//  Created by James Pacheco on 11/18/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {
    
    var editProfile = false
    var isCurrentUserProfile = true
    var isEvaluateProfile = true

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var firstPersonLabel: UILabel!
    @IBOutlet weak var secondPersonLabel: UILabel!
    @IBOutlet weak var firstPersonAboutLabel: UILabel!
    @IBOutlet weak var aboutCoupleLabel: UILabel!
    @IBOutlet weak var secondPersonAboutLabel: UILabel!
    @IBOutlet weak var interestsLabel: UILabel!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        updateWithProfile(ProfileController.SharedInstance.currentUserProfile)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Response Buttons Actions
    
    @IBAction func rejectButtonTapped(sender: AnyObject) {
    }
    
    @IBAction func likeButtonTapped(sender: AnyObject) {
    }
    
    func updateWithProfile(profile: Profile) {
        let firstPerson = profile.people.0
        let secondPerson = profile.people.1
        
        titleLabel.text = "\(firstPerson.name) & \(secondPerson.name)"
        //imageView.image = profile.profilePicture
        if let about = profile.about {
            aboutCoupleLabel.text = about
        }
        
        firstPersonLabel.text = "\(firstPerson.name) (\(firstPerson.age)-\(firstPerson.gender.rawValue)):"
        secondPersonLabel.text = "\(secondPerson.name) (\(secondPerson.age)-\(secondPerson.gender.rawValue)):"
        
        if let firstPersonAbout = firstPerson.about {
            firstPersonAboutLabel.text = firstPersonAbout
        }
        
        if let secondPersonAbout = secondPerson.about {
            secondPersonAboutLabel.text = secondPersonAbout
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
