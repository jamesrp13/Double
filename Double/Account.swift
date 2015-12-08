//
//  Account.swift
//  Double
//
//  Created by James Pacheco on 12/5/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

struct Account: FirebaseType {
    let email: String
    var identifier: String?
    
    var endpoint: String {
        return "accounts"
    }
    
    var jsonValue: [String: AnyObject] {
        let json: [String: AnyObject] = ["email": email]
        return json
    }
    
    init?(json: [String : AnyObject], identifier: String) {
        guard let email = json["email"] as? String else {return nil}
        self.email = email
        self.identifier = identifier
    }
    
    init(email: String, identifier: String) {
        self.email = email
        self.identifier = identifier
    }
}