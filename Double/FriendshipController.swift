//
//  FriendshipController.swift
//  Double
//
//  Created by James Pacheco on 11/19/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

class FriendshipController {

    static let SharedInstance = FriendshipController()
    
    static let kFriendshipsChanged = "FriendshipsChanged"
    
    var friendships: [Friendship] = [] {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName(FriendshipController.kFriendshipsChanged, object: self)
        }
    }
    
    var friendshipIdentifiers: [String] {
        var friendshipIdentifiers: [String] = []
        for friendship in friendships {
            friendshipIdentifiers.append(friendship.identifier!)
        }
        return friendshipIdentifiers
    }
    
    static func observeFriendshipsForCurrentUser() {
        FriendshipController.observeFriendshipsForProfileIdentifier(ProfileController.SharedInstance.currentUserProfile.identifier!) { (friendships) -> Void in
            if var friendships = friendships {
                var modifiedFriendships: [Friendship] = []
                let tunnel = dispatch_group_create()
                for var friendship in friendships {
                    dispatch_group_enter(tunnel)
                    MessageController.observeMessagesForFriendshipIdentifier(friendship.identifier!, completion: { (messages) -> Void in
                        if let messages = messages {
                            friendship.messages = messages
                        }
                        print(friendship.identifier!)
                        modifiedFriendships.append(friendship)
                        dispatch_group_leave(tunnel)
                    })
                }
                dispatch_group_notify(tunnel, dispatch_get_main_queue(), { () -> Void in
                    SharedInstance.friendships = modifiedFriendships
                })
            }
        }
    }
    
    static func observeFriendshipsForProfileIdentifier(profileIdentifier: String, completion: (friendships: [Friendship]?) -> Void) {
        FirebaseController.base.childByAppendingPath("friendships").queryOrderedByChild(profileIdentifier).queryEqualToValue(true).observeEventType(.Value, withBlock: { (data) -> Void in
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
            print(friendship.identifier!)
        }
        return conversations
    }
    
    static func createFriendship(profileIdentifier1: String, profileIdentifier2: String) {
        var friendship = Friendship(profileIdentifiers: (profileIdentifier1, profileIdentifier2))
        friendship.save()
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