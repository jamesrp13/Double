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
    var coupleTitle: String {
        return "\(people.0.name) and \(people.1.name)"
    }
    var married: Bool
    var relationshipStart: NSDate
    var about: String?
    var location: String
    var children: [Child]?
    var imageEndPoint: String
    var profilePicture: UIImage? {
        ImageController.imageForIdentifier(imageEndPoint) { (image) -> Void in
            return image
        }
        return nil
    }
    var friendships: [Friendship]?
    var responses: [Response]?
    
    // FirebaseType attributes and failable initializer
    var identifier: String?
    
    var endpoint: String {
        return "profiles"
    }
    
    var jsonValue: [String: AnyObject] {
        var json: [String: AnyObject] = [kMarried: married, kRelationshipStart: relationshipStart.timeIntervalSince1970, kLocation: location, kImageEndpoint: imageEndPoint]
        
        if let about = about {
            json.updateValue(about, forKey: kAbout)
        }
        return json
    }
    
    init?(json: [String : AnyObject], identifier: String) {
        var peopleTuple: (Person, Person)? = nil
        var childrenArray: [Child]? = nil
        var friendshipArray: [Friendship]? = nil
        var responsesArray: [Response]? = nil
        
        // Fetch necessary data not included in json
        PersonController.fetchPeopleForProfileIdentifier(identifier) { (people) -> Void in
            peopleTuple = people
        }
        
        ChildController.fetchChildrenForProfileIdentifier(identifier) { (children) -> Void in
            childrenArray = children
        }
        
        FriendshipController.fetchFriendshipsForProfileIdentifier(identifier) { (friendships) -> Void in
            friendshipArray = friendships
        }
        
        ResponseController.fetchResponsesForIdentifier(identifier) { (responses) -> Void in
            responsesArray = responses
        }
        
        guard let married = json[kMarried] as? Bool,
            let location = json[kLocation] as? String,
            let imageEndPoint = json[kImageEndpoint] as? String,
            let people = peopleTuple,
            let children = childrenArray,
            let friendships = friendshipArray,
            let relationshipTimeInterval = json[kRelationshipStart] as? NSTimeInterval,
            let responses = responsesArray else {return nil}
        
        self.identifier = identifier
        self.married = married
        self.relationshipStart = NSDate(timeIntervalSince1970: relationshipTimeInterval)
        self.location = location
        self.imageEndPoint = imageEndPoint
        self.about = json[kAbout] as? String
        self.people = people
        self.children = children
        self.friendships = friendships
        self.responses = responses
        
    }
    
    // Standard initializer
    init(people: (Person, Person), married: Bool, relationshipStart: NSDate, about: String?, location: String, children: [Child]? = nil, imageEndPoint: String, friendships: [Friendship]? = nil, responses: [Response]? = nil, identifier: String? = nil) {
        
        self.people = people
        self.married = married
        self.relationshipStart = relationshipStart
        self.about = about
        self.location = location
        self.children = children
        self.imageEndPoint = imageEndPoint
        self.friendships = friendships
        self.responses = responses
        self.identifier = identifier
    }
    
    
}