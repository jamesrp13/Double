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
    
    var currentUserProfile: Profile? = nil
    
    var currentUserIdentifier: String? = nil
    
    var profilesBeingViewed: [Profile] = [] {
        didSet {
            if oldValue.count != 0 && profilesBeingViewed.count > 0{
                if profilesBeingViewed.count < 10 && (oldValue[0].identifier! != profilesBeingViewed[0].identifier!) {
                    ProfileController.fetchProfileForDisplay()
                }
                if profilesBeingViewed.count > 0 && (oldValue[0].identifier! != profilesBeingViewed[0].identifier!) {
                    NSNotificationCenter.defaultCenter().postNotificationName("ProfilesChanged", object: self)
                }
            } else {
                if profilesBeingViewed.count < 10 {
                    ProfileController.fetchProfileForDisplay()
                }
                if profilesBeingViewed.count > 0 {
                    NSNotificationCenter.defaultCenter().postNotificationName("ProfilesChanged", object: self)
                }
            }
            ProfileController.SharedInstance.saveProfileIdentifiersToPersistentStore()
        }
    }
    
    var profileIdentifiers: [String] {
        var profileIdentifiers: [String] = []
        for profile in profilesBeingViewed {
            profileIdentifiers.append(profile.identifier!)
        }
        return profileIdentifiers
    }
    
    var responsesFromProfilesBeingViewed: [String: Bool] = [:]
    
    func saveProfileIdentifiersToPersistentStore() {
        if let profile = ProfileController.SharedInstance.currentUserProfile {
            NSUserDefaults.standardUserDefaults().setObject(profileIdentifiers, forKey: "\(profile.identifier!)profileIdentifiers")
            NSUserDefaults.standardUserDefaults().synchronize()
        }
    }
    
    // MARK: - CRUD
    
    static func createProfile(var people: (Person, Person), relationshipStatus: Profile.RelationshipStatus, relationshipStart: NSDate, about: String?, location: String, children: [Child]?, image: UIImage, profileIdentifier: String, completion: (profile: Profile?) -> Void) {
        
        ImageController.uploadImage(image) { (imageIdentifier) -> Void in
            if let imageIdentifier = imageIdentifier {
                var profile = Profile(people: people, relationshipStatus: relationshipStatus, relationshipStart: relationshipStart, about: about, location: location, children: children, imageEndPoint: imageIdentifier, identifier: profileIdentifier)
                profile.save()
                
                // Save children
                ChildController.saveChildren(children)
                
                // Set profileIdentifier for people, then save everything
                people.0.profileIdentifier = profile.identifier!
                people.0.save()
                people.1.profileIdentifier = profile.identifier!
                people.1.save()
                
                // When profile is created, responses must be created in Firebase as well despite there being none, so let's create a false response from the profile's own profile
                var response = Responses(profileViewedByIdentifier: profile.identifier!, like: false, profileIdentifier: profile.identifier!)
                response.save()
                
                completion(profile: profile)
            } else {
                completion(profile: nil)
            }
        }
        
    }
    
//    static func updateProfile(oldProfile: Profile, image: UIImage, married: Bool, relationshipStart: NSDate, about: String?, location: String, children: [Child]?, imageEndPoint: String, completion: (success: Bool, profile: Profile?) -> Void) {
//        
//        ImageController.replaceImage(image, identifier: oldProfile.imageEndPoint) { (identifier) -> Void in
//            if let identifier = identifier {
//                let profile = Profile(people: oldProfile.people, married: married, relationshipStart: relationshipStart, about: about, location: location, children: children, imageEndPoint: identifier, identifier: oldProfile.identifier!)
//                
//                ProfileController.saveProfile(profile)
//                
//                completion(success: true, profile: profile)
//            } else {
//                completion(success: false, profile: nil)
//            }
//        }
//    }
    
    static func saveProfile(var profile: Profile) {
        PersonController.savePeople(profile.people)
        ChildController.saveChildren(profile.children)
        profile.save()
    }
    
    static func deleteProfile(profile: Profile) {
        profile.delete()
        PersonController.deletePeople(profile.people)
        ImageController.deleteImage(profile.imageEndPoint)
        ChildController.deleteChildren(profile.children)
        ResponseController.deleteResponsesForProfileIdentifier(profile.identifier!)
    }
    
    // MARK: - Prepare profiles for viewing
    
    static func fetchProfileForDisplay() {
        fetchUnseenProfiles { (profiles) -> Void in
            if let profiles = profiles {
                guard profiles.count > 0 else {return}
                
                let tunnel = dispatch_group_create()
                for profile in profiles {
                    dispatch_group_enter(tunnel)
                    ResponseController.createResponse(profile.identifier!, liked: false, completion: { (responses) -> Void in
                        if let _ = responses {
                            dispatch_group_leave(tunnel)
                        }
                    })
                }
                dispatch_group_notify(tunnel, dispatch_get_main_queue(), { () -> Void in
                    ProfileController.SharedInstance.profilesBeingViewed += profiles
                    ProfileController.observeResponsesFromProfiles(profiles)
                })
            }
        }
    }
    
    static func fetchUnseenProfiles(completion: (profiles: [Profile]?) -> Void) {

        // Fetches from Firebase a dictionary of responses to find profiles that have not yet been viewed
        FirebaseController.base.childByAppendingPath("responses").queryOrderedByChild(SharedInstance.currentUserProfile!.identifier!).queryLimitedToFirst(10).queryEndingAtValue(nil).observeSingleEventOfType(.Value, withBlock: { (data) -> Void in
            if let responseDictionaries = data.value as? [String: AnyObject] {
                let profileIdentifiers = responseDictionaries.flatMap({$0.0})
                
                var profiles: [Profile] = []
                let tunnel = dispatch_group_create()
                
                for profileIdentifier in profileIdentifiers {
                    dispatch_group_enter(tunnel)
                    fetchProfileForIdentifier(profileIdentifier, completion: { (profile) -> Void in
                        if let profile = profile {
                            profiles.append(profile)
                        }
                        dispatch_group_leave(tunnel)
                    })
                }
                
                dispatch_group_notify(tunnel, dispatch_get_main_queue()) { () -> Void in
                    completion(profiles: profiles)
                    print("\rWe pulled down \(profiles.count) profiles\r")
                }
                
            } else {
                completion(profiles: nil)
                print("\rThere are no more profiles to be seen\r")
            }
        })
    }
    
    
    static func fetchProfileForIdentifier(profileIdentifier: String, completion: (profile: Profile?) -> Void) {
        
        FirebaseController.base.childByAppendingPath("profiles/\(profileIdentifier)").observeSingleEventOfType(.Value, withBlock: { (profileSnapshot) -> Void in
            
            if let profileAttributeDictionary = profileSnapshot.value as? [String: AnyObject] {
               
                // Fetch data for people and children
                ChildController.fetchChildrenDataForProfileIdentifier(profileIdentifier, completion: { (childrenDictionary) -> Void in
                    
                    PersonController.fetchPeopleDataForProfileIdentifier(profileIdentifier, completion: { (peopleDictionary) -> Void in
                        let children = childrenDictionary ?? [:]
                        if let people = peopleDictionary {
                            let profileJson = ["profiles": profileAttributeDictionary, "children": children, "people": people]
                            if let profile = Profile(json: profileJson, identifier: profileIdentifier) {
                                completion(profile: profile)
                                
                            } else {
                                completion(profile: nil)
                            }
                        } else {
                            completion(profile: nil)
                        }
                    })
                })
            } else {
                completion(profile: nil)
            }
        })
    }
    
    static func observeResponsesFromProfiles(profiles: [Profile]) {
        for profile in profiles {
            ResponseController.observeResponsesFromIdentifier(profile.identifier!, completion: { (responses) -> Void in
                if let responses = responses {
                    if let response = responses.responsesDictionary[profile.identifier!] {
                        SharedInstance.responsesFromProfilesBeingViewed.updateValue(response, forKey: profile.identifier!)
                    }
                }
            })
        }
    }
    
    
    static func checkForMatch(profileIdentifier: String) {
        if let liked = SharedInstance.responsesFromProfilesBeingViewed[profileIdentifier] {
            if liked {
                FriendshipController.createFriendship(profileIdentifier, profileIdentifier2: SharedInstance.currentUserProfile!.identifier!)
                print("It's a match with \(profileIdentifier)!")
            } else {
                print("We'll let you know if \(profileIdentifier) are interested in meeting up")
            }
        } else {
            print("We'll let you know if \(profileIdentifier) are interested in meeting up")
        }
    }

    
    static func mockProfiles() -> [Profile] {
        let couples = [(PersonController.mockPeople()[0], PersonController.mockPeople()[1]), (PersonController.mockPeople()[2], PersonController.mockPeople()[3])]
        
        let children = [ChildController.mockChildren()[0]]
        
        let profile1 = Profile(people: couples[0], relationshipStatus: Profile.RelationshipStatus(rawValue: "Married")!, relationshipStart: NSDate(timeIntervalSince1970: 0.0), about: "Test", location: "84109", children: [children[0]], imageEndPoint: "", identifier: "K3pg5XfBBcEwOQk50Li")
        
        let profile2 = Profile(people: couples[1], relationshipStatus: Profile.RelationshipStatus(rawValue: "Married")!, relationshipStart: NSDate(timeIntervalSince1970: 0.0), about: "Test", location: "84109", children: nil, imageEndPoint: "", identifier: "K3pg5XfBBcEwO2ndof0")
        
        return [profile1, profile2]
    }
    
}