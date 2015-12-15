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
            if oldValue != friendships {
                for (index, var friendship) in friendships.enumerate() {
                    FriendshipController.observeConversationForFriendshipIdentifier(friendship.identifier!, completion: { (messages) -> (Void) in
                        if let newMessages = messages {
                            if let oldMessages = friendship.messages {
                                if oldMessages != newMessages {
                                    friendship.messages = newMessages
                                        self.friendships[index] = friendship
                                    }
                            } else {
                                friendship.messages = newMessages
                                    self.friendships[index] = friendship   
                            }
                        }
                    })
                }
                NSNotificationCenter.defaultCenter().postNotificationName(FriendshipController.kFriendshipsChanged, object: self)
            }
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
        FriendshipController.observeFriendshipsForProfileIdentifier(ProfileController.SharedInstance.currentUserIdentifier!) { (friendships) -> Void in
            if let friendships = friendships {
                SharedInstance.friendships = friendships
            }
        }
    }
    
    
    static func observeConversationForFriendshipIdentifier(friendshipIdentifier: String, completion: (messages: [Message]?) -> (Void)) {
        MessageController.observeMessagesForFriendshipIdentifier(friendshipIdentifier, completion: { (messages) -> Void in
            if let messages = messages {
                completion(messages: messages)
            } else {
                completion(messages: nil)
            }
        })
    }
    
    static func observeFriendshipsForProfileIdentifier(profileIdentifier: String, completion: (friendships: [Friendship]?) -> Void) {
        FirebaseController.base.childByAppendingPath("friendships").queryOrderedByChild(profileIdentifier).queryEqualToValue(true).observeEventType(.Value, withBlock: { (data) -> Void in
            if let friendshipDictionaries = data.value as? [String: AnyObject] {
                let friendships = friendshipDictionaries.flatMap({Friendship(json: $0.1 as! [String: AnyObject], identifier: $0.0)
                })
                FirebaseController.base.childByAppendingPath("friendships").queryOrderedByChild(profileIdentifier).queryEqualToValue(true).observeEventType(FEventType.ChildRemoved, withBlock: { (data) -> Void in
                    guard let key = data.key else {return}
                    completion(friendships: friendships.filter({$0.identifier! != key}).sort({$0.identifier! < $1.identifier!}))
                })
                completion(friendships: friendships.sort({$0.identifier! < $1.identifier!}))
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
        return conversations.sort({$0.messages!.last!.identifier! > $1.messages!.last!.identifier!})
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