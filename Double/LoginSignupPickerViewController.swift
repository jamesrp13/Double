//
//  LoginSignupPickerViewController.swift
//  Double
//
//  Created by James Pacheco on 12/6/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class LoginSignupPickerViewController: UIViewController {

    @IBOutlet weak var mainStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        setupConstraints()
    }

    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func setupConstraints() {
        let topConstraint = NSLayoutConstraint(item: mainStackView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: self.view.frame.height / 6)
        let bottomConstraint = NSLayoutConstraint(item: mainStackView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: -self.view.frame.height / 5)
        
        self.view.addConstraint(topConstraint)
        self.view.addConstraint(bottomConstraint)
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
