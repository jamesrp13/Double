//
//  ResponseController.swift
//  Double
//
//  Created by James Pacheco on 11/19/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

class ResponseController {
    
    static func fetchResponsesForIdentifier(profileIdentifier: String, completion: (responses: [Response]) -> Void) {
        FirebaseController.base.childByAppendingPath("responses").childByAppendingPath(profileIdentifier).observeSingleEventOfType(.Value, withBlock: { (data) -> Void in
            if let responseDictionaries = data.value as? [String: Bool] {
                let response = Response(json: responseDictionaries, identifier: profileIdentifier)
                print(response)
            }
        })
    }
    
    static func mockResponses() -> [Response] {
        let response1 = Response(profileViewedByIdentifier: "820fhs8", like: true, profileIdentifier: "02dkj")
        
        return [response1]
    }
    
    
}