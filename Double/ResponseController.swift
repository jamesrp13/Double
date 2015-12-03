//
//  ResponseController.swift
//  Double
//
//  Created by James Pacheco on 11/19/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

class ResponseController {
    
    static func fetchResponsesForIdentifier(profileIdentifier: String, completion: (responses: Responses?) -> Void) {
        FirebaseController.base.childByAppendingPath("responses/\(profileIdentifier)").observeSingleEventOfType(.Value, withBlock: { (data) -> Void in

            if let responseDictionaries = data.value as? [String: Bool] {
                let responses = Responses(json: responseDictionaries, identifier: profileIdentifier)
                completion(responses: responses)
            } else {
            completion(responses: nil)
            }
        })
    }
    
    static func observeResponsesFromIdentifier(profileIdentifier: String, completion: (responses: Responses?) -> Void) {
        FirebaseController.base.childByAppendingPath("responses/\(ProfileController.SharedInstance.currentUserProfile.identifier!)/\(profileIdentifier)").observeEventType(.Value, withBlock: { (data) -> Void in
            
            if let value = data.value as? Bool {
                let responses = Responses(profileViewedByIdentifier: profileIdentifier, like: value, profileIdentifier: ProfileController.SharedInstance.currentUserProfile.identifier!)
                completion(responses: responses)
            } else {
                completion(responses: nil)
            }
        })

    }
    
    static func createResponse(profileViewed: String, profileViewedBy: String = ProfileController.SharedInstance.currentUserProfile.identifier!, liked: Bool, completion: (responses: Responses?) -> Void ) {
        var response = Responses(profileViewedByIdentifier: profileViewedBy, like: liked, profileIdentifier: profileViewed)
        response.save()
        FirebaseController.base.childByAppendingPath("responses").childByAppendingPath(profileViewed).childByAppendingPath(profileViewedBy).observeSingleEventOfType(.Value, withBlock: { (data) -> Void in
            if let _ = data {
                completion(responses: response)
            } else {
                completion(responses: nil)
            }
        })
    }
    
    static func deleteResponsesForProfileIdentifier(profileIdentifier: String) {
        // Delete responses about this profile
        fetchResponsesForIdentifier(profileIdentifier) { (responses) -> Void in
            if let responses = responses {
                responses.delete()
            }
        }
        
        // Delete responses made by this profile
        
    }
    
    
    
    static func mockResponses() -> Responses {
        let responses = Responses(profileViewedByIdentifier: "-K3payZu8I9HP6MG1ovV", like: true, profileIdentifier: "-K3payZogAH6iaX0I-VM")
        
        return responses
    }
    
    
}