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
                completion(messages)
            } else {
                completion(nil)
            }
        })

    }
    
    static func deleteMessage(message: Message) {
        
        message.delete()
        
    }
    
    static func mockMessages() -> [Message] {
        let message1 = Message(friendshipId: "92fido", profileId: "29fdjkw", text: "This is a test message")
        
        return [message1]
        
    }
}