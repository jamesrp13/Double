//
//  Response.swift
//  Double
//
//  Created by James Pacheco on 11/18/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

struct Response: FirebaseType {
    
    var responseDictionary: [String: Bool]
    
    // FirebaseType attributes and failable initializer
    var identifier: String?
    var endpoint: String {
        return "responses"
    }
    
    var jsonValue: [String: AnyObject] {
        return responseDictionary
    }
    
    init?(json: [String : AnyObject], identifier: String) {
        guard let json = json as? [String: Bool] else {return nil}
        
        self.responseDictionary = json
        self.identifier = identifier
    }
    
    // Standard initializer
    init(profileViewedByIdentifier: String, like: Bool, profileIdentifier: String) {
        self.responseDictionary = [profileViewedByIdentifier: like]
        self.identifier = profileIdentifier
    }
    
}