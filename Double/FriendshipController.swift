//
//  FriendshipController.swift
//  Double
//
//  Created by James Pacheco on 11/19/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

class FriendshipController {

    static func fetchFriendshipsForProfileIdentifier(profileIdentifier: String, completion: (friendships: [Friendship]) -> Void) {
        
    }
    
    static func conversationsForFriendships(friendships: [Friendship]) -> [Friendship] {
        var conversations: [Friendship] = []
        for friendship in friendships {
            if friendship.messages.count != 0 {
                conversations.append(friendship)
            }
        }
        return conversations
    }
    
    static func mockFriendships() -> [Friendship] {
        let friendship1 = Friendship(profileIdentifiers: ("k92hd92h", "sonw9n4"), messages: MessageController.mockMessages())
        return [friendship1]
    }
}