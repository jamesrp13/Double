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
    
    static func mockFriendships() -> [Friendship] {
        let friendship1 = Friendship(profileIdentifiers: ("k92hd92h", "sonw9n4"))
        return [friendship1]
    }
}