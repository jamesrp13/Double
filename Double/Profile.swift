//
//  Profile.swift
//  Double
//
//  Created by James Pacheco on 11/18/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit
import CoreLocation


struct Profile: FirebaseType, Equatable {
    
    // Constants for fetching data from Firebase dictionaries
    private let kRelationshipStatus = "relationshipStatus"
    private let kRelationshipStart = "NSDate"
    private let kAbout = "about"
    private let kLocation = "location"
    private let kImageEndpoint = "imageEndpoint"
    private let kProfiles = "profiles"
    private let kPeople = "people"
    private let kChildren = "children"
    
    enum RelationshipStatus: String {
        case Dating = "dating"
        case Engaged = "engaged"
        case Married = "married"
    }
    
    // Profile attributes
    let people: (Person, Person)
    var relationshipStatus: RelationshipStatus
    var relationshipStart: NSDate
    var about: String?
    var location: CLLocation
    var children: [Child]?
    var imageEndPoint: String
    
    // Profile computed variables
    var coupleTitle: String {
        return "\(people.0.name) and \(people.1.name)"
    }
    
    var relationshipLength: String? {
        var lengthString = ""
        let years = relationshipStart.timeIntervalSinceNow/(-365)/24/60/60
        let months = (relationshipStart.timeIntervalSinceNow)/(-24)/60/60/30
        if years < 1 {
            lengthString = Int(round(months)) == 1 ? "\(Int(round(months))) month":"\(Int(round(months))) months"
        } else {
            if months%12 >= 4 && months%12 <= 8 {
                lengthString = "\(Int(round(years))) and a half years"
            } else {
                lengthString = Int(round(years)) == 1 ? "\(Int(round(years))) year":"\(Int(round(years))) years"
            }
        }
        return lengthString
    }

    
    // FirebaseType attributes and failable initializer
    var identifier: String?
    
    var endpoint: String {
        return "profiles"
    }
    
    var jsonValue: [String: AnyObject] {
        let locationDictionary = ["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude]
        var json: [String: AnyObject] = [kRelationshipStatus: relationshipStatus.rawValue, kRelationshipStart: relationshipStart.timeIntervalSince1970, kLocation: locationDictionary, kImageEndpoint: imageEndPoint]
        
        if let about = about {
            json.updateValue(about, forKey: kAbout)
        }
        return json
    }
    
    var jsonValueForPersisting: [String: AnyObject] {
        let locationDictionary = ["latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude]
        var profileJson: [String: AnyObject] = [kRelationshipStatus: relationshipStatus.rawValue, kRelationshipStart: relationshipStart.timeIntervalSince1970, kLocation: locationDictionary, kImageEndpoint: imageEndPoint]
        
        if let about = about {
            profileJson.updateValue(about, forKey: kAbout)
        }
        
        let peopleJson: [String: AnyObject] = [people.0.identifier!: people.0.jsonValue, people.1.identifier!: people.1.jsonValue]
        var childrenJson: [String: AnyObject] = [:]
        if let children = children {
            for child in children {
                childrenJson.updateValue(child.jsonValue, forKey: child.identifier!)
            }
        }
        
        var json: [String: AnyObject] = [kProfiles: profileJson, kPeople: peopleJson]
        if childrenJson.count > 0 {
            json.updateValue(childrenJson, forKey: kChildren)
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
        if let childDictionaries = json[kChildren] as? [String: AnyObject] {
            children = childDictionaries.flatMap({Child(json: $0.1 as! [String: AnyObject], identifier: $0.0)})
        }
    
        guard let profileDictionary = json[kProfiles] as? [String: AnyObject] else {return nil}
        
        guard let relationshipStatusString = profileDictionary[kRelationshipStatus] as? String,
            relationshipStatus = Profile.RelationshipStatus(rawValue: relationshipStatusString) else {return nil}
        guard let imageEndPoint = profileDictionary[kImageEndpoint] as? String,
            let people = peopleTuple,
            let relationshipTimeInterval = profileDictionary[kRelationshipStart] as? NSTimeInterval,
            let locationDictionary = profileDictionary[kLocation] as? [String: Double],
            latitude = locationDictionary["latitude"],
            longitude = locationDictionary["longitude"] else {return nil}
        
        self.identifier = identifier
        self.relationshipStatus = relationshipStatus
        self.relationshipStart = NSDate(timeIntervalSince1970: relationshipTimeInterval)
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        self.imageEndPoint = imageEndPoint
        self.about = profileDictionary[kAbout] as? String
        self.people = people
        self.children = children
    }

    
    // Standard initializer
    init(people: (Person, Person), relationshipStatus: RelationshipStatus, relationshipStart: NSDate, about: String?, location: CLLocation, children: [Child]?, imageEndPoint: String, identifier: String?) {
        
        self.people = people
        self.relationshipStatus = relationshipStatus
        self.relationshipStart = relationshipStart
        self.about = about
        self.location = location
        self.children = children
        self.imageEndPoint = imageEndPoint
        self.identifier = identifier
    }
    
    
}

func == (lhs: Profile, rhs: Profile) -> Bool {
    return lhs.identifier! == rhs.identifier!
}