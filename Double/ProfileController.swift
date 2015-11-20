//
//  ProfileController.swift
//  Double
//
//  Created by James Pacheco on 11/19/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class ProfileController {
    
    static let SharedInstance = ProfileController()
    
    var currentUserProfile: Profile = ProfileController.mockProfiles()[0]

    
    static func createProfile(people: (Person, Person), married: Bool, relationshipStart: NSDate, about: String?, location: String, children: [Child], image: UIImage, friendships: [Friendship], responses: [Response], completion: (success: Bool, profile: Profile?) -> Void) {
        
        ImageController.uploadImage(image) { (identifier) -> Void in
            if let identifier = identifier {
                var profile = Profile(people: people, married: married, relationshipStart: relationshipStart, about: about, location: location, children: children, imageEndPoint: identifier, friendships: friendships, responses: responses)
                profile.save()
                completion(success: true, profile: profile)
            } else {
                completion(success: false, profile: nil)
            }
        }
        
    }
    
    static func profileForIdentifier(profileIdentifier: String, completion: (profile: Profile?) -> Void) {
        
        completion(profile: mockProfiles()[1])
    }
    
    static func mockProfiles() -> [Profile] {
        //let relationshipStart = NSDate(timeIntervalSince1970: 0.0)
       // let person1 = PersonController.mockPeople()[0]
        //let person2 = PersonController.mockPeople()[1]
        
        //let profile0 = Profile(people: (person1, person2), married: true, relationshipStart: relationshipStart, about: "test", location: "84109", children: [], imageEndPoint: "nothing", friendships: [], responses: [])
        
        let profile1 = Profile(people: (PersonController.mockPeople()[0], PersonController.mockPeople()[1]), married: true, relationshipStart: NSDate(timeIntervalSince1970: 0.0), about: "Test", location: "84109", children: [ChildController.mockChildren()[0]], imageEndPoint: "", friendships: FriendshipController.mockFriendships(), responses: ResponseController.mockResponses(), identifier: "k92hd92h" )
        
        let profile2 = Profile(people: (PersonController.mockPeople()[2], PersonController.mockPeople()[3]), married: false, relationshipStart: NSDate(timeIntervalSince1970: 0.0), about: "Cool people", location: "84109", children: [], imageEndPoint: "", friendships: FriendshipController.mockFriendships(), responses: ResponseController.mockResponses(), identifier: "sonw9n4")
        
        return [profile1, profile2]
    }
    
}