//
//  Message.swift
//  Double
//
//  Created by James Pacheco on 11/18/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

struct Message: FirebaseType {
    private let kFriendshipId = "friendshipId"
    private let kProfileId = "profileId"
    private let kText = "text"
    
    var friendshipId: String
    var profileId: String
    var text: String
    
    // FirebaseType attributes and failable initializer
    var identifier: String?
    var jsonValue: [String: AnyObject] {
        let json: [String: AnyObject] = [kFriendshipId: friendshipId, kProfileId: profileId, kText: text]
        return json
    }
    var endpoint: String {
        return "messages"
    }
    
    init?(json: [String : AnyObject], identifier: String) {
        guard let friendshipId = json[kFriendshipId] as? String,
            let profileId = json[kProfileId] as? String,
            let text = json[kText] as? String else {return nil}
        
        self.friendshipId = friendshipId
        self.profileId = profileId
        self.text = text
        self.identifier = identifier
    }
    
    // Standard initializer
    init(friendshipId: String, profileId: String, text: String) {
        self.friendshipId = friendshipId
        self.profileId = profileId
        self.text = text
    }
}