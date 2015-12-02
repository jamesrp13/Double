//
//  MessageController.swift
//  Double
//
//  Created by James Pacheco on 11/19/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

class MessageController {
    
    static func observeMessagesForFriendshipIdentifier(friendshipIdentifier: String, completion: ([Message]?) -> Void) {
        FirebaseController.base.childByAppendingPath("messages").queryOrderedByChild("friendshipId").queryEqualToValue(friendshipIdentifier).observeEventType(.Value, withBlock: { (data) -> Void in
            if let messageDictionaries = data.value as? [String: AnyObject] {
                let messages = messageDictionaries.flatMap({Message(json: $0.1 as! [String: AnyObject], identifier: $0.0)
                })
                completion(messages.sort({$0.identifier! < $1.identifier!}))
            } else {
                completion(nil)
            }
        })
    }
    
    static func observeLastMessageForFriendshipIdentifier(friendshipIdentifier: String, completion: (Message?) -> Void) {
        FirebaseController.base.childByAppendingPath("messages").queryOrderedByChild("friendshipId").queryEqualToValue(friendshipIdentifier).queryLimitedToLast(1).observeEventType(.Value, withBlock: { (data) -> Void in
            if let messageDictionaries = data.value as? [String: AnyObject] {
                let messages = messageDictionaries.flatMap({Message(json: $0.1 as! [String: AnyObject], identifier: $0.0)
                })
                completion(messages[0])
            } else {
                completion(nil)
            }
        })
    }
    
    static func createMessage(friendship: Friendship, text: String, senderProfileIdentifier: String) {
        var message = Message(friendshipId: friendship.identifier!, profileId: senderProfileIdentifier, text: text)
        message.save()
    }
    
    static func deleteMessage(message: Message) {
        
        message.delete()
        
    }
    
    static func mockMessages() -> [Message] {
        let message1 = Message(friendshipId: "92fido", profileId: "29fdjkw", text: "This is a test message")
        
        return [message1]
        
    }
}