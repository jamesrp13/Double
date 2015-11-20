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
    
    static func mockResponses() -> [Response] {
        let response1 = Response(profileViewedId: "820fhs8", like: true, identifier: "02dkj")
        
        return [response1]
    }
}