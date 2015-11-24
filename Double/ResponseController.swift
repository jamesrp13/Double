//
//  ResponseController.swift
//  Double
//
//  Created by James Pacheco on 11/19/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

class ResponseController {
    
    static func fetchResponsesForIdentifier(profileIdentifier: String, completion: (responses: [Response]?) -> Void) {
        FirebaseController.base.childByAppendingPath("responses/\(profileIdentifier)").observeSingleEventOfType(.Value, withBlock: { (data) -> Void in

            if let responseDictionaries = data.value as? [String: Bool] {
                let responses = responseDictionaries.flatMap({Response(profileViewedByIdentifier: $0.0, like: $0.1, profileIdentifier: profileIdentifier)})
                completion(responses: responses)
            } else {
            completion(responses: nil)
            }
        })
    }
    
//    static func createResponse(profileViewed: String, profileViewedBy: String = ProfileController.SharedInstance.currentUserProfile.identifier!, liked: Bool, completion: (success: Bool, response: Response?) -> Void ) {
//        var response = Response(profileViewedByIdentifier: profileViewedBy, like: liked, profileIdentifier: profileViewed)
//        response.save()
//        FirebaseController.base.childByAppendingPath("profiles").childByAppendingPath(profileViewed).childByAppendingPath("responses").childByAppendingPath(profileViewed).updateChildValues(response.jsonValue)
//    }
    
    static func deleteResponse(response: Response) {
        response.delete()
    }
    
    static func mockResponses() -> [Response] {
        let response1 = Response(profileViewedByIdentifier: "-K3payZu8I9HP6MG1ovV", like: true, profileIdentifier: "-K3payZogAH6iaX0I-VM")
        
        return [response1]
    }
    
    
}