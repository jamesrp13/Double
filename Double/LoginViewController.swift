//
//  LoginViewController.swift
//  Double
//
//  Created by James Pacheco on 12/6/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController, UITextFieldDelegate {

    var account: Account? = nil
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var mainStackView: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        setupConstraints()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func setupConstraints() {
        let topConstraint = NSLayoutConstraint(item: mainStackView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1, constant: self.view.frame.height / 6)
        let bottomConstraint = NSLayoutConstraint(item: mainStackView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 1, constant: -self.view.frame.height / 5)
        
        self.view.addConstraint(topConstraint)
        self.view.addConstraint(bottomConstraint)
    }
    
    @IBAction func loginTapped(sender: AnyObject) {
        guard let email = emailTextField.text, password = passwordTextField.text else {presentAlert("Please enter login credentials", message: "") ; return}
        
        AccountController.authenticateAccount(email, password: password, completion: { (account) -> Void in
            if let account = account {
                ProfileController.fetchProfileForIdentifier(account.identifier!, completion: { (profile) -> Void in
                    if let profile = profile {
                        ImageController.imageForIdentifier(profile.imageEndPoint, completion: { (image) -> Void in
                            if let tabBarController = self.presentingViewController as? UITabBarController {
                                if let navController = tabBarController.viewControllers?.first as? UINavigationController {
                                    let profileViewController = navController.viewControllers.first! as! ProfileTableViewController
                                    if let image = image {
                                        profileViewController.ourProfileButton.setImage(image, forState: .Normal)
                                        self.dismissViewControllerAnimated(true, completion: nil)
                                    } else {
                                        print("There is no image for the current user profile!")
                                    }
                                }
                            }
                        })
                    } else {
                        self.dismissViewControllerAnimated(true, completion: nil)
                    }
                })
            } else {
                self.presentAlert("Authentication failed", message: "Please check your email and password and try again.")
            }
        })
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        return true
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
