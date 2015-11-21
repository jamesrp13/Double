//
//  ResponseController.swift
//  Double
//
//  Created by James Pacheco on 11/19/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

class ResponseController {
    
    static func fetchResponsesForProfileIdentifier(profileIdentifier: String, completion: (responses: [Response]) -> Void) {
    
    }
    
    static func fetchResponsesForIdentifier(profileIdentifier: String) {
        FirebaseController.base.childByAppendingPath("responses").queryOrderedByChild(profileIdentifier).queryEqualToValue(profileIdentifier).observeSingleEventOfType(.Value, withBlock: { (data) -> Void in
            if let responseDictionaries = data.value as? [String: AnyObject] {
                let responsesTuple = responseDictionaries.flatMap({$0})
            
            }
        })
    }
    
    static func mockResponses() -> [Response] {
        let response1 = Response(profileViewedByIdentifier: "820fhs8", like: true, profileIdentifier: "02dkj")
        
        return [response1]
    }
    
    
}