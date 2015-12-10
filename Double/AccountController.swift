//
//  AccountController.swift
//  Double
//
//  Created by James Pacheco on 12/5/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

class AccountController {
    
    static func createAccount(email: String, password: String, passwordRetyped: String, completion: (account: Account?) -> Void) {
        if self.isValidEmail(email) && self.isValidPassword(password) && (password == passwordRetyped) {
            FirebaseController.base.createUser(email, password: password) { (error, response) -> Void in
                if error != nil {
                    print(error)
                    completion(account: nil)
                } else {
                    if let accountIdentifier = response["uid"] as? String {
                        var account = Account(email: email, identifier: accountIdentifier)
                        account.save()
                        
                        authenticateAccount(email, password: password, completion: { (account) -> Void in
                            if let account = account {
                                print("Account creation successful")
                                completion(account: account)
                            } else {
                                print("Account not created")
                                completion(account: nil)
                            }
                        })
                        
                    } else {
                        print("Account not created")
                        completion(account: nil)
                    }
                }
            }
        } else {
            print("Invalid email or password")
        }
    }
    
    static func authenticateAccount(email: String, password: String, completion: (account: Account?) -> Void) {
        FirebaseController.base.authUser(email, password: password) { (error, authData) -> Void in
            if error != nil {
                completion(account: nil)
            } else {
                fetchAccountForIdentifier(authData.uid, completion: { (account) -> Void in
                    if let account = account {
                        ProfileController.SharedInstance.currentUserIdentifier = account.identifier
                        ProfileController.fetchProfileForIdentifier(account.identifier!, completion: { (profile) -> Void in
                            if let profile = profile {
                                ProfileController.SharedInstance.currentUserProfile = profile
                                FirebaseController.loadNecessaryDataFromNetwork()
                            }
                            ProfileController.SharedInstance.currentUserIdentifier = account.identifier!
                            completion(account: account)
                        })
                    } else {
                        completion(account: nil)
                    }
                })
            }
        }
    }
    
    static func logoutCurrentUser(completion: () -> Void) {
        ProfileController.SharedInstance.currentUserProfile = nil
        ProfileController.SharedInstance.currentUserIdentifier = nil
        FriendshipController.SharedInstance.friendships = []
        ProfileController.SharedInstance.responsesFromProfilesBeingViewed = [:]
        completion()
    }
    
    static func isValidEmail(testStr:String) -> Bool {
        // println("validate calendar: \(testStr)")
        let emailRegEx = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluateWithObject(testStr)
    }
    
    static func isValidPassword(password: String) -> Bool {
        guard password.characters.count >= 5 else {return false}
        return true
    }
    
    static func fetchAccountForIdentifier(identifier: String, completion: (account: Account?) -> Void) {
        FirebaseController.base.childByAppendingPath("accounts").childByAppendingPath(identifier).observeSingleEventOfType(.Value, withBlock: { (data) -> Void in
            if let email = data.value["email"] as? String {
                let account = Account(email: email, identifier: identifier)
                completion(account: account)
            } else {
                completion(account: nil)
            }
        })
    }
}