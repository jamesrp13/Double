//
//  Response.swift
//  Double
//
//  Created by James Pacheco on 11/18/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

struct Response: FirebaseType {
    private let kProfileViewedId = "profileId"
    private let kLike = "like"
    
    var profileViewedId: String
    var like: Bool
    
    // FirebaseType attributes and failable initializer
    var identifier: String?
    var endpoint: String {
        return "responses"
    }
    
    var jsonValue: [String: AnyObject] {
        let json: [String: AnyObject] = [kProfileViewedId: profileViewedId, kLike: like]
        return json
    }
    
    init?(json: [String : AnyObject], identifier: String) {
        guard let profileViewedId = json[kProfileViewedId] as? String,
            let like = json[kLike] as? Bool else {return nil}
        
        self.profileViewedId = profileViewedId
        self.like = like
        self.identifier = identifier
    }
    
    // Standard initializer
    init(profileViewedId: String, like: Bool, identifier: String) {
        self.profileViewedId = profileViewedId
        self.like = like
        self.identifier = identifier
    }
    
}