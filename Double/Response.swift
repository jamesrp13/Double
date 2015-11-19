//
//  Response.swift
//  Double
//
//  Created by James Pacheco on 11/18/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

struct Response: FirebaseType {
    private let kProfileId = "profileId"
    private let kLike = "like"
    
    var profileId: String
    var like: Bool
    
    // FirebaseType attributes and failable initializer
    var identifier: String?
    var endpoint: String {
        return "responses"
    }
    
    var jsonValue: [String: AnyObject] {
        let json: [String: AnyObject] = [kProfileId: profileId, kLike: like]
        return json
    }
    
    init?(json: [String : AnyObject], identifier: String) {
        guard let profileId = json[kProfileId] as? String,
            let like = json[kLike] as? Bool else {return nil}
        
        self.profileId = profileId
        self.like = like
        self.identifier = identifier
    }
    
    // Standard initializer
    init(profileId: String, like: Bool) {
        self.profileId = profileId
        self.like = like
    }
    
}