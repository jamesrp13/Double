//
//  Friendship.swift
//  Double
//
//  Created by James Pacheco on 11/18/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

struct Friendship: FirebaseType, Equatable {
    
    var profileIdentifiers: (String, String)
    var messages: [Message]?
    
    // FirebaseType attributes and failable initializer
    var identifier: String?
    var jsonValue: [String: AnyObject] {
        let json: [String: AnyObject] = [profileIdentifiers.0: true, profileIdentifiers.1: true]
        return json
    }
    
    var endpoint: String {
        return "friendships"
    }
    
    init?(json: [String : AnyObject], identifier: String) {
        
        let profileIdentifiers = json.flatMap({$0.0})
        guard profileIdentifiers.count == 2 else {return nil}
        
        self.profileIdentifiers = (profileIdentifiers[0], profileIdentifiers[1])
        self.messages = nil
        self.identifier = identifier
    }
    
    // Standard initializer
    init(profileIdentifiers: (String, String), messages: [Message]? = nil, identifier: String? = nil) {
        self.profileIdentifiers = profileIdentifiers
        self.messages = messages
        self.identifier = identifier
    }
}

func == (lhs: Friendship, rhs: Friendship) -> Bool {
    guard (lhs.profileIdentifiers.0 == rhs.profileIdentifiers.0 || lhs.profileIdentifiers.0 == rhs.profileIdentifiers.1) &&
        (rhs.profileIdentifiers.0 == lhs.profileIdentifiers.1 || rhs.profileIdentifiers.0 == lhs.profileIdentifiers.0) &&
        lhs.identifier == rhs.identifier else {return false}
    return true
}