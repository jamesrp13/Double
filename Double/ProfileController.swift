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

    
    static func createProfile(people: (Person, Person), married: Bool, relationshipStart: NSDate, about: String?, location: String, children: [Child]?, image: UIImage, friendships: [Friendship]?, responses: [Response]?, completion: (success: Bool, profile: Profile?) -> Void) {
        
        ImageController.uploadImage(image) { (identifier) -> Void in
            if let identifier = identifier {
                var profile = Profile(people: people, married: married, relationshipStart: relationshipStart, about: about, location: location, children: children, imageEndPoint: identifier, friendships: friendships, responses: responses)
                profile.save()
                
                // Set profileIdentifier for people, then save
                var person1 = people.0
                person1.profileIdentifier = profile.identifier
                var person2 = people.1
                person2.profileIdentifier = profile.identifier
                person1.save()
                person2.save()
                
                // Save children if not nil
                if let children = children {
                    for var child in children {
                        child.profileIdentifier = profile.identifier
                        child.save()
                    }
                }
                // When profile is created, responses must be created in Firebase as well despite there being none, so let's create a false response from the profile's own profile
                if let responses = responses {
                    for var response in responses {
                        response.identifier = profile.identifier
                        response.save()
                    }
                } else {
                    var response = Response(profileViewedByIdentifier: profile.identifier!, like: false, profileIdentifier: profile.identifier!)
                    response.save()
                }
                
                // Save friendships if any
                if let friendships = friendships {
                    for var friendship in friendships {
                        friendship.save()
                    }
                }

                completion(success: true, profile: profile)
            } else {
                completion(success: false, profile: nil)
            }
        }
        
    }
    
    static func fetchUnseenProfiles(completion: (profiles: [Profile]?) -> Void) {
        
        // Fetches from Firebase a dictionary of responses to find profiles that have not yet been viewed
        FirebaseController.base.childByAppendingPath("responses").queryOrderedByChild(SharedInstance.currentUserProfile.identifier!).queryEqualToValue(nil).queryLimitedToFirst(20).observeEventType(.Value, withBlock: { (data) -> Void in
            if let responseDictionaries = data.value as? [String: AnyObject] {
                let profileIdentifiers = responseDictionaries.flatMap({$0.0})
                for profileIdentifier in profileIdentifiers {
                    
                    FirebaseController.base.childByAppendingPath("profiles/\(profileIdentifier)").observeSingleEventOfType(.Value, withBlock: { (data) -> Void in
                        print(data.value)
                    })
                }
            }
        })
    }
    
    static func fetchProfileForIdentifier(profileIdentifier: String, completion: (profile: Profile?) -> Void) {
        
        completion(profile: mockProfiles()[1])
    }
    
    static func mockProfiles() -> [Profile] {
        //let relationshipStart = NSDate(timeIntervalSince1970: 0.0)
       // let person1 = PersonController.mockPeople()[0]
        //let person2 = PersonController.mockPeople()[1]
        
        //let profile0 = Profile(people: (person1, person2), married: true, relationshipStart: relationshipStart, about: "test", location: "84109", children: [], imageEndPoint: "nothing", friendships: [], responses: [])
        
        let profile1 = Profile(people: (PersonController.mockPeople()[0], PersonController.mockPeople()[1]), married: true, relationshipStart: NSDate(timeIntervalSince1970: 0.0), about: "Test", location: "84109", children: [ChildController.mockChildren()[0]], imageEndPoint: "", friendships: FriendshipController.mockFriendships(), responses: ResponseController.mockResponses(), identifier: "-K3pg5XfBBcEwOQk50Li" )
        
        let profile2 = Profile(people: (PersonController.mockPeople()[2], PersonController.mockPeople()[3]), married: false, relationshipStart: NSDate(timeIntervalSince1970: 0.0), about: "Cool people", location: "84109", children: [], imageEndPoint: "", friendships: FriendshipController.mockFriendships(), responses: ResponseController.mockResponses(), identifier: "sonw9n4")
        
        return [profile1, profile2]
    }
    
}