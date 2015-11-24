//
//  Profile.swift
//  Double
//
//  Created by James Pacheco on 11/18/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

struct Profile: FirebaseType {
    
    // Constants for fetching data from Firebase dictionaries
    private let kMarried = "married"
    private let kRelationshipStart = "NSDate"
    private let kAbout = "about"
    private let kLocation = "location"
    private let kImageEndpoint = "imageEndpoint"
    private let kProfiles = "profiles"
    private let kPeople = "people"
    private let kChildren = "children"
    
    // Profile attributes
    let people: (Person, Person)
    var married: Bool
    var relationshipStart: NSDate
    var about: String?
    var location: String
    var children: [Child]?
    var imageEndPoint: String
    
    // Profile computed variables
    var coupleTitle: String {
        return "\(people.0.name) and \(people.1.name)"
    }
    
    var profilePicture: UIImage? {
        ImageController.imageForIdentifier(imageEndPoint) { (image) -> Void in
            return image
        }
        return nil
    }
    
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
        var children: [Child]? = nil
        
        // Guard against not having two people, set people
        guard let peopleDictionaries = json[kPeople] as? [String: AnyObject] else {return nil}
            let peopleArray = peopleDictionaries.flatMap({Person(json: $0.1 as! [String: AnyObject], identifier: $0.0)})
            if peopleArray.count == 2 {
                peopleTuple = (peopleArray[0], peopleArray[1])
            } else {
                return nil
            }
        
        // Guard against network call to children failing, set children
        guard let childDictionaries = json[kChildren] as? [String: AnyObject] else {return nil}
            children = childDictionaries.flatMap({Child(json: $0.1 as! [String: AnyObject], identifier: $0.0)})
    
        
        guard let married = json[kMarried] as? Bool else {return nil}
        guard let location = json[kLocation] as? String else {return nil}
        guard let imageEndPoint = json[kImageEndpoint] as? String else {return nil}
        guard let people = peopleTuple else {return nil}
        guard let relationshipTimeInterval = json[kRelationshipStart] as? NSTimeInterval else {return nil}
        
        self.identifier = identifier
        self.married = married
        self.relationshipStart = NSDate(timeIntervalSince1970: relationshipTimeInterval)
        self.location = location
        self.imageEndPoint = imageEndPoint
        self.about = json[kAbout] as? String
        self.people = people
        self.children = children
    }
    
//    init?(json: [String : AnyObject], people: (Person, Person), children: [Child]?, identifier: String) {
//        
//        guard let married = json[kMarried] as? Bool,
//            let location = json[kLocation] as? String,
//            let imageEndPoint = json[kImageEndpoint] as? String,
//            let relationshipTimeInterval = json[kRelationshipStart] as? NSTimeInterval else {return nil}
//        
//        self.identifier = identifier
//        self.married = married
//        self.relationshipStart = NSDate(timeIntervalSince1970: relationshipTimeInterval)
//        self.location = location
//        self.imageEndPoint = imageEndPoint
//        self.about = json[kAbout] as? String
//        self.people = people
//        self.children = children
//        
//    }

    
    // Standard initializer
    init(people: (Person, Person), married: Bool, relationshipStart: NSDate, about: String?, location: String, children: [Child]?, imageEndPoint: String, identifier: String? = nil) {
        
        self.people = people
        self.married = married
        self.relationshipStart = relationshipStart
        self.about = about
        self.location = location
        self.children = children
        self.imageEndPoint = imageEndPoint
        self.identifier = identifier
    }
    
    
}