//
//  Friendship.swift
//  Double
//
//  Created by James Pacheco on 11/18/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

struct Friendship: FirebaseType {
    
    private let kProfileIdentifiers = "profileIdentifiers"
    
    var profileIdentifiers: (String, String)
    var messages: [Message]
    
    // FirebaseType attributes and failable initializer
    var identifier: String?
    var jsonValue: [String: AnyObject] {
        let json: [String: AnyObject] = [kProfileIdentifiers: [profileIdentifiers.0, profileIdentifiers.1]]
        return json
    }
    var endpoint: String {
        return "friendships"
    }
    init?(json: [String : AnyObject], identifier: String) {
        
        var messageArray: [Message]? = nil
        
        MessageController.fetchMessagesForFriendshipIdentifier(identifier) { (messages) -> Void in
            messageArray = messages
        }
        
        guard let profileIdentifiers = json[kProfileIdentifiers] as? (String, String),
            let messages = messageArray else {return nil}
        
        self.profileIdentifiers = profileIdentifiers
        self.messages = messages
        self.identifier = identifier
    }
    
    // Standard initializer
    init(profileIdentifiers: (String, String), messages: [Message] = [], identifier: String? = nil) {
        self.profileIdentifiers = profileIdentifiers
        self.messages = messages
        self.identifier = identifier
    }
}