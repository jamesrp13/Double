//
//  FirebaseController.swift
//  Double
//
//  Created by James Pacheco on 11/18/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation
import Firebase

class FirebaseController {
    
    static let base = Firebase(url: "https://doubledate.firebaseio.com/")
    static let geoFire = GeoFire(firebaseRef: base)
    
    static func dataAtEndpoint(endpoint: String, completion: (data:AnyObject?) -> Void)  {
        let baseForEndpoint = FirebaseController.base.childByAppendingPath(endpoint)
        
        baseForEndpoint.observeSingleEventOfType(.Value, withBlock: { (snapshot) -> Void in
            if snapshot.value is NSNull {
                completion(data: nil)
            } else {
                completion(data: snapshot.value)
            }
        })
    }
    
    static func observeDataAtEndpoint(endpoint: String, completion: (data: AnyObject?) -> Void) {
        let baseForEndpoint = FirebaseController.base.childByAppendingPath(endpoint)
        
        baseForEndpoint.observeEventType(.Value, withBlock: { snapshot in
            
            if snapshot.value is NSNull {
                completion(data: nil)
            } else {
                completion(data: snapshot.value)
            }
        })
    }
    
    static func loadNecessaryDataFromNetwork() {
        if let profile = ProfileController.SharedInstance.currentUserProfile {
            let profileIdentifiers = NSUserDefaults.standardUserDefaults().objectForKey("\(profile.identifier!)profileIdentifiers")
            var profiles: [Profile] = []
            
            let tunnel = dispatch_group_create()
            
            if let profileIdentifiers = profileIdentifiers as? [String] {
                for profileIdentifier in profileIdentifiers {
                    dispatch_group_enter(tunnel)
                    ProfileController.fetchProfileForIdentifier(profileIdentifier, completion: { (profile) -> Void in
                        if let profile = profile {
                            profiles.append(profile)
                        }
                        dispatch_group_leave(tunnel)
                    })
                }
            }
            
            dispatch_group_notify(tunnel, dispatch_get_main_queue()) { () -> Void in
                if profiles.count > 0 {
                    ProfileController.SharedInstance.profilesBeingViewed = profiles
                    ProfileController.observeResponsesFromProfiles(profiles)
                    print("\(profiles.count) profile identifiers in persistent storage")
                } else {
                    ProfileController.fetchProfileForDisplay()
                    print("No profile identifiers in persistent storage -- fetching profiles for display")
                }
                
            }
            
            FriendshipController.observeFriendshipsForCurrentUser()
        }
    }
}

protocol FirebaseType {
    var identifier: String? {get set}
    var endpoint: String {get}
    var jsonValue: [String: AnyObject] {get}
    
    init?(json: [String:AnyObject], identifier: String)
    
    mutating func save()
    func delete()
}

extension FirebaseType {
    mutating func save() {
        var endpointBase: Firebase
        
        if let identifier = self.identifier {
            endpointBase = FirebaseController.base.childByAppendingPath(endpoint).childByAppendingPath(identifier)
        } else {
            endpointBase = FirebaseController.base.childByAppendingPath(endpoint).childByAutoId()
            self.identifier = endpointBase.key
        }
        endpointBase.updateChildValues(jsonValue)
    }
    
    func delete() {
        if let identifier = self.identifier {
            let endpointBase: Firebase = FirebaseController.base.childByAppendingPath(endpoint).childByAppendingPath(identifier)
            
            endpointBase.removeValue()
        }
    }
}