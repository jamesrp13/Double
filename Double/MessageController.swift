//
//  MessageController.swift
//  Double
//
//  Created by James Pacheco on 11/19/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

class MessageController {
    
    static func fetchMessagesForFriendshipIdentifier(friendshipIdentifier: String, completion: ([Message]) -> Void) {
    
    }
    
    
    static func mockMessages() -> [Message] {
        let message1 = Message(friendshipId: "92fido", profileId: "29fdjkw", text: "This is a test message")
        
        return [message1]
    }
}