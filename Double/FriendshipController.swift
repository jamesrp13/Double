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
//            if oldValue != friendships {
//                for (index, var friendship) in friendships.enumerate() {
//                    FriendshipController.observeConversationForFriendshipIdentifier(friendship.identifier!, completion: { (messages) -> (Void) in
//                        if let newMessages = messages {
//                            if let oldMessages = friendship.messages {
//                                if oldMessages != newMessages {
//                                    friendship.messages = newMessages
//                                        self.friendships[index] = friendship
//                                    }
//                            } else {
//                                friendship.messages = newMessages
//                                    self.friendships[index] = friendship   
//                            }
//                        }
//                    })
//                }
                NSNotificationCenter.defaultCenter().postNotificationName(FriendshipController.kFriendshipsChanged, object: self)
//            }
        }
    }
    
    
    var friendshipDictionary: [String:Friendship] = [:] {
        didSet {
            friendships = Array(friendshipDictionary.values).sort({$0.1.identifier! > $0.1.identifier!})
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
        FriendshipController.observeFriendshipsAddedForProfileIdentifier(ProfileController.SharedInstance.currentUserIdentifier!) { (friendship) -> Void in
            if let friendship = friendship {
                SharedInstance.friendshipDictionary[friendship.identifier!] = friendship
            }
        }
        FriendshipController.observeFriendshipsRemovedForProfileIdentifier(ProfileController.SharedInstance.currentUserIdentifier!) { (friendshipIdentifier) -> Void in
            if let friendshipIdentifier = friendshipIdentifier {
                SharedInstance.friendshipDictionary.removeValueForKey(friendshipIdentifier)
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
    
    static func observeFriendshipsAddedForProfileIdentifier(profileIdentifier: String, completion: (friendship: Friendship?) -> Void) {
        FirebaseController.base.childByAppendingPath("friendships").queryOrderedByChild(profileIdentifier).queryEqualToValue(true).observeEventType(.ChildAdded, withBlock: { (data) -> Void in
            if let friendshipDictionary = data.value as? [String: AnyObject],
                let friendshipKey = data.key {
                    if var friendship = Friendship(json: friendshipDictionary, identifier: friendshipKey) {
                        let friendProfileIdentifier = friendship.profileIdentifiers.0 != ProfileController.SharedInstance.currentUserIdentifier! ? friendship.profileIdentifiers.0:friendship.profileIdentifiers.1
                        ProfileController.fetchProfileForIdentifier(friendProfileIdentifier, completion: { (profile) -> Void in
                            if let profile = profile {
                                ProfileController.fetchImageForProfile(profile, completion: { (image) -> Void in
                                    if let image = image {
                                        friendship.image = image
                                        MessageController.observeMessagesForFriendshipIdentifier(friendship.identifier!, completion: { (messages) -> Void in
                                            if let messages = messages {
                                                friendship.messages = messages.sort({$0.0.identifier! < $0.1.identifier!})
                                                completion(friendship: friendship)
                                            } else {
                                                completion(friendship: friendship)
                                            }
                                        })
                                    } else {
                                        completion(friendship: nil)
                                        print("No image found for friendship \(friendship.identifier!)")
                                    }
                                })
                            } else {
                                completion(friendship: nil)
                                print("No profile found for friendship \(friendship.identifier!)")
                            }
                        })
                    } else {
                        completion(friendship: nil)
                        print("Friendship not initialized for friendship \(friendshipKey)")
                    }
            } else {
                completion(friendship: nil)
            }
        })
    }
    
    static func observeFriendshipsRemovedForProfileIdentifier(profileIdentifier: String, completion: (friendshipIdentifier: String?) -> Void) {
        FirebaseController.base.childByAppendingPath("friendships").queryOrderedByChild(profileIdentifier).queryEqualToValue(true).observeEventType(FEventType.ChildRemoved, withBlock: { (data) -> Void in
            guard let key = data.key else {completion(friendshipIdentifier: nil);return}
            completion(friendshipIdentifier: key)
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