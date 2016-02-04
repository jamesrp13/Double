//
//  CreateAccountViewController.swift
//  Double
//
//  Created by James Pacheco on 12/6/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class CreateAccountViewController: UIViewController, UITextFieldDelegate {

    var account: Account? = nil
    
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var passwordRetypedTextField: UITextField!
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
    
    @IBAction func createAccountTapped(sender: AnyObject) {
        guard let email = emailTextField.text where AccountController.isValidEmail(email) else {presentAlert("Invalid Email", message: "Please enter a valid email to continue"); return}
        
        guard let password = passwordTextField.text, passwordRetyped = passwordRetypedTextField.text where password == passwordRetyped && AccountController.isValidPassword(password) else {presentAlert("Invalid Password", message: "Please enter a password greater than 5 characters using at least one number and one letter"); return}
        
        let loadingVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("loadingVC")
        loadingVC.modalPresentationStyle = .OverFullScreen
        presentViewController(loadingVC, animated: true, completion: nil)
        
        AccountController.createAccount(email, password: password, passwordRetyped: passwordRetyped, completion: { (account) -> Void in
            if let account = account {
                self.account = account
                self.performSegueWithIdentifier("createAccount", sender: self)
                self.dismissViewControllerAnimated(false, completion: nil)
            }
        })


    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        passwordRetypedTextField.resignFirstResponder()
        return true
    }

    // MARK: - Navigation

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "createAccount" {
            if let basicInfoView = segue.destinationViewController as? BasicInfoViewController {
                basicInfoView.accountIdentifier = account?.identifier!
            }
        }
    }

}
