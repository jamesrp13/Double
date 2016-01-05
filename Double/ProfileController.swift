//
//  ProfileController.swift
//  Double
//
//  Created by James Pacheco on 11/19/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit
import CoreLocation

class ProfileController {
    
    private let kUser = "kUser"
    static let SharedInstance = ProfileController()
    
    var currentUserProfile: Profile! {
        get{
            guard let uid = FirebaseController.base.authData?.uid,
                let profileDictionary = NSUserDefaults.standardUserDefaults().valueForKey(kUser) as? [String: AnyObject] else {return nil}
            guard let profile = Profile(json: profileDictionary, identifier: uid) else {return nil}
            currentUserIdentifier = profile.identifier!
            return profile
            
        }
        
        set{
            
            if let newValue = newValue {
                NSUserDefaults.standardUserDefaults().setValue(newValue.jsonValueForPersisting, forKey: kUser)
                NSUserDefaults.standardUserDefaults().synchronize()
                currentUserIdentifier = newValue.identifier!
            } else {
                NSUserDefaults.standardUserDefaults().removeObjectForKey(kUser)
                NSUserDefaults.standardUserDefaults().synchronize()
            }
        }
    }

    var profilesLeft = true
    var currentUserIdentifier: String? = nil
    
    var profilesBeingViewed: [Profile] = [] {
        didSet {
            NSNotificationCenter.defaultCenter().postNotificationName("profilesBeingViewedChanged", object: self)
            saveProfileIdentifiersToPersistentStore()
            if profilesLeft && profilesBeingViewed.count < 10 {
                ProfileController.fetchProfileForDisplay()
            }
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
    
    static func createProfile(var people: (Person, Person), relationshipStatus: Profile.RelationshipStatus, relationshipStart: NSDate, about: String?, location: CLLocation, children: [Child]?, image: UIImage, profileIdentifier: String, completion: (profile: Profile?) -> Void) {
        
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
                
                // Save location
                let geofire = GeoFire(firebaseRef: FirebaseController.base.childByAppendingPath("locations"))
                geofire.setLocation(location, forKey: profileIdentifier)
                
                // When profile is created, responses must be created in Firebase as well despite there being none, so let's create a false response from the profile's own profile
                var response = Responses(profileViewedByIdentifier: profile.identifier!, like: false, profileIdentifier: profile.identifier!)
                response.save()
                
                //Fetch profile from Firebase to be sure that it was uploaded
                ProfileController.fetchProfileForIdentifier(profileIdentifier, completion: { (profile) -> Void in
                    completion(profile: profile)
                })
            } else {
                completion(profile: nil)
            }
        }
        
    }
    
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
        SharedInstance.profilesLeft = true
        SharedInstance.fetchRegionalProfileIdentifiers { (profilesIdentifiers) -> Void in
            if let profileIdentifiers = profilesIdentifiers {
                SharedInstance.filterForUnseenProfiles(profileIdentifiers, unseenProfileIdentifiers: [], completion: { (profileIdentifiers) -> Void in
                    if let profileIdentifiers = profileIdentifiers where profileIdentifiers.count > 0 {
                        for profileIdentifier in profileIdentifiers {
                            fetchProfileForIdentifier(profileIdentifier, completion: { (profile) -> Void in
                                if let profile = profile {
                                    ResponseController.createResponse(profile.identifier!, liked: false, completion: { (responses) -> Void in
                                        if let _ = responses {
                                            observeResponsesFromProfiles([profile])
                                            SharedInstance.profilesBeingViewed.append(profile)
                                        }
                                    })
                                }
                            })
                        }
                    } else {
                        SharedInstance.profilesLeft = false
                    }
                })
            }
        }
    }
    
    func fetchRegionalProfileIdentifiers(completion: (profilesIdentifiers: [String]?) -> Void) {
        let location = self.currentUserProfile!.location
        let geofire = GeoFire(firebaseRef: FirebaseController.base.childByAppendingPath("locations"))
        let query = geofire.queryAtLocation(location, withRadius: 80)
        query.observeSingleEventOfTypeValue { (locations) -> Void in
            if let locationDictionary = locations as? [String: CLLocation] {
                let profileIdentifiers = Array(locationDictionary.keys)
                completion(profilesIdentifiers: profileIdentifiers)
            }
        }
    }
    
    func filterForUnseenProfiles(profileIdentifiers: [String], unseenProfileIdentifiers: [String], completion: (profileIdentifiers: [String]?) -> Void) {
        if profileIdentifiers.count > 0 {
            ResponseController.fetchResponsesForIdentifier(profileIdentifiers[0], completion: { (responses) -> Void in
                if let responses = responses where responses.responsesDictionary[self.currentUserIdentifier!] == nil {
                    let unseenProfileIdentifiers = unseenProfileIdentifiers + [profileIdentifiers[0]]
                    if unseenProfileIdentifiers.count >= 10 {
                        completion(profileIdentifiers: unseenProfileIdentifiers)
                    } else {
                        var profileIdentifiers = profileIdentifiers
                        profileIdentifiers.removeFirst()
                        self.filterForUnseenProfiles(profileIdentifiers, unseenProfileIdentifiers: unseenProfileIdentifiers) { (profileIdentifiers) -> Void in
                            completion(profileIdentifiers: profileIdentifiers)
                        }
                    }
                } else {
                    print("We've already seen the profile for \(profileIdentifiers[0])")
                    var profileIdentifiers = profileIdentifiers
                    profileIdentifiers.removeFirst()
                    self.filterForUnseenProfiles(profileIdentifiers, unseenProfileIdentifiers: unseenProfileIdentifiers) { (profileIdentifiers) -> Void in
                        completion(profileIdentifiers: profileIdentifiers)
                    }
                }
            })
        } else {
            print("There are no more profiles to be seen in the area")
            completion(profileIdentifiers: unseenProfileIdentifiers)
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
                            let _ = Profile(json: profileJson, identifier: profileIdentifier, completion: { (profile) -> Void in
                                if var profile = profile {
                                    ImageController.imageForIdentifier(profile.imageEndPoint, completion: { (image) -> Void in
                                        if let image = image {
                                            profile.image = image
                                            LocationController.locationAsCityCountry(profile.location, completion: { (cityState) -> Void in
                                                if let cityState = cityState {
                                                    profile.locationAsString = cityState
                                                    completion(profile: profile)
                                                } else {
                                                    print("Location fetched for profile doesn't register as a real city")
                                                }
                                            })
                                        } else {
                                            print("No image found when profile fetched")
                                        }
                                    })
                                } else {
                                    completion(profile: nil)
                                }
                            })
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

    static func fetchImageForProfile(profile: Profile, completion: (image: UIImage?)->Void) {
        ImageController.imageForIdentifier(profile.imageEndPoint) { (image) -> Void in
            if let image = image {
                completion(image: image)
            } else {
                completion(image: nil)
            }
        }
    }
//    
//    static func mockProfiles() -> [Profile] {
//        let couples = [(PersonController.mockPeople()[0], PersonController.mockPeople()[1]), (PersonController.mockPeople()[2], PersonController.mockPeople()[3])]
//        
//        let children = [ChildController.mockChildren()[0]]
//        
//        let profile1 = Profile(people: couples[0], relationshipStatus: Profile.RelationshipStatus(rawValue: "Married")!, relationshipStart: NSDate(timeIntervalSince1970: 0.0), about: "Test", location: "84109", children: [children[0]], imageEndPoint: "", identifier: "K3pg5XfBBcEwOQk50Li")
//        
//        let profile2 = Profile(people: couples[1], relationshipStatus: Profile.RelationshipStatus(rawValue: "Married")!, relationshipStart: NSDate(timeIntervalSince1970: 0.0), about: "Test", location: "84109", children: nil, imageEndPoint: "", identifier: "K3pg5XfBBcEwO2ndof0")
//        
//        return [profile1, profile2]
//    }
    
}