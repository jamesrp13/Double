//
//  ChildController.swift
//  Double
//
//  Created by James Pacheco on 11/19/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

class ChildController {
    
    static func fetchChildrenForProfileIdentifier(profileIdentifier: String, completion: (children: [Child]) -> Void) {
        
    }
    
    static func mockChildren() -> [Child] {
        let child1 = Child(dob: NSDate(timeIntervalSinceNow: (-1.0)*365*24*60*60), gender: Child.Gender.Female)
        let child2 = Child(dob: NSDate(timeIntervalSinceNow: (-1.0)*365*24*60*60), gender: Child.Gender.Male)
        let child3 = Child(dob: NSDate(timeIntervalSinceNow: (-1.0)*365*24*60*60), gender: Child.Gender.Female)
        
        return [child1, child2, child3]
    }
}