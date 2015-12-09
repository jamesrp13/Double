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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func presentAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Try again", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    @IBAction func loginTapped(sender: AnyObject) {
        guard let email = emailTextField.text, password = passwordTextField.text else {presentAlert("Please enter login credentials", message: "") ; return}
        
        AccountController.authenticateAccount(email, password: password, completion: { (account) -> Void in
            if let account = account {
                ProfileController.fetchProfileForIdentifier(account.identifier!, completion: { (profile) -> Void in
                    self.dismissViewControllerAnimated(true, completion: nil)
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
