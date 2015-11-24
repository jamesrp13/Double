//
//  FriendshipController.swift
//  Double
//
//  Created by James Pacheco on 11/19/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

class FriendshipController {

    static func fetchFriendshipsForProfileIdentifier(profileIdentifier: String, completion: (friendships: [Friendship]?) -> Void) {
        FirebaseController.base.childByAppendingPath("friendships").queryOrderedByChild(profileIdentifier).queryEqualToValue(true).observeSingleEventOfType(.Value, withBlock: { (data) -> Void in
            if let friendshipDictionaries = data.value as? [String: AnyObject] {
                let friendships = friendshipDictionaries.flatMap({Friendship(json: $0.1 as! [String: AnyObject], identifier: $0.0)
                })
                completion(friendships: friendships)
            } else {
                completion(friendships: nil)
            }
        })
    }
    
    
    static func conversationsForFriendships(friendships: [Friendship]) -> [Friendship] {
        var conversations: [Friendship] = []
        for friendship in friendships {
            if let _ = friendship.messages {
                conversations.append(friendship)
            }
        }
        return conversations
    }
    
    static func deleteFriendship(friendship: Friendship) {
        friendship.delete()
        
        if let messages = friendship.messages {
            for message in messages {
                MessageController.deleteMessage(message)
            }
        }
        
    }
    
    static func mockFriendships() -> [Friendship] {
        let friendship1 = Friendship(profileIdentifiers: ("k92hd92h", "sonw9n4"), messages: MessageController.mockMessages())
        return [friendship1, friendship1, friendship1, friendship1, friendship1]
    }
}