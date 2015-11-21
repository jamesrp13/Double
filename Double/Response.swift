//
//  Response.swift
//  Double
//
//  Created by James Pacheco on 11/18/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

struct Response: FirebaseType {
    private let kProfileViewedByIdentifier = "profileViewedByIdentifier"
    private let kLike = "like"
    
    var profileViewedByIdentifier: String
    var like: Bool
    
    // FirebaseType attributes and failable initializer
    var identifier: String?
    var endpoint: String {
        return "responses"
    }
    
    var jsonValue: [String: AnyObject] {
        let json: [String: AnyObject] = [profileViewedByIdentifier: like]
        return json
    }
    
    init?(json: [String : AnyObject], identifier: String) {
        let jsonAsArray = json.flatMap({$0})
        let profileViewedByIdentifier = jsonAsArray[0].0
        guard let like = jsonAsArray[0].1 as? Bool else {return nil}
        
        self.profileViewedByIdentifier = profileViewedByIdentifier
        self.like = like
        self.identifier = identifier
    }
    
    // Standard initializer
    init(profileViewedByIdentifier: String, like: Bool, profileIdentifier: String) {
        self.profileViewedByIdentifier = profileViewedByIdentifier
        self.like = like
        self.identifier = profileIdentifier
    }
    
}