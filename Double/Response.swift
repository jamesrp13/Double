//
//  Response.swift
//  Double
//
//  Created by James Pacheco on 11/18/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

struct Responses: FirebaseType {
    
    var responsesDictionary: [String: Bool]
    
    // FirebaseType attributes and failable initializer
    var identifier: String?
    var endpoint: String {
        return "responses"
    }
    
    var jsonValue: [String: AnyObject] {
        return responsesDictionary
    }
    
    init?(json: [String : AnyObject], identifier: String) {
        guard let json = json as? [String: Bool] else {return nil}
        
        self.responsesDictionary = json
        self.identifier = identifier
    }
    
    // Standard initializer
    init(profileViewedByIdentifier: String, like: Bool, profileIdentifier: String) {
        self.responsesDictionary = [profileViewedByIdentifier: like]
        self.identifier = profileIdentifier
    }
}