//
//  Profile.swift
//  Double
//
//  Created by James Pacheco on 11/18/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

struct Profile: FirebaseType {
    
    private let kMarried = "married"
    private let kRelationshipStart = "NSDate"
    private let kAbout = "about"
    private let kLocation = "location"
    private let kImageEndpoint = "imageEndpoint"
    
    let people: (Person, Person)
    var married: Bool
    var relationshipStart: NSDate
    var about: String?
    var location: String
    var children: [Child]
    var imageEndPoint: String
    var profilePicture: UIImage? {
        ImageController.imageForIdentifier(imageEndPoint) { (image) -> Void in
            return image
        }
        return nil
    }
    var friendships: [Friendship]
    var responses: [Response]
    
    // FirebaseType attributes
    var identifier: String?
    
    var endpoint: String {
        return "profiles"
    }
    
    var jsonValue: [String: AnyObject] {
        var json: [String: AnyObject] = [kMarried: married, kRelationshipStart: relationshipStart, kLocation: location, kImageEndpoint: imageEndPoint]
        
        if let about = about {
            json.updateValue(about, forKey: kAbout)
        }
        return json
    }
    
    init?(json: [String : AnyObject], identifier: String) {
        guard let married = json[kMarried] as? Bool,
            let relationshipStart = json[kRelationshipStart] as? NSDate,
            let location = json[kLocation] as? String,
            let imageEndPoint = json[kImageEndpoint] as? String else {return nil}
        
        self.married = married
        self.relationshipStart = relationshipStart
        self.location = location
        self.imageEndPoint = imageEndPoint
        self.about = json[kAbout] as? String
        self.people
        self.children
        self.friendships
        self.responses
    }
    
    
}