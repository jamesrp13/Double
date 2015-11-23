//
//  ChildController.swift
//  Double
//
//  Created by James Pacheco on 11/19/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

class ChildController {
    
    static func fetchChildrenForProfileIdentifier(profileIdentifier: String, completion: (children: [Child]?) -> Void) {
        FirebaseController.base.childByAppendingPath("children").queryOrderedByChild("profileIdentifier").queryEqualToValue(profileIdentifier).observeSingleEventOfType(.Value, withBlock: { (data) -> Void in
            if let childrenDictionaries = data.value as? [String: AnyObject] {
                let children = childrenDictionaries.flatMap({Child(json: $0.1 as! [String: AnyObject], identifier: $0.0)})
                    completion(children: children)
        
            } else {
                completion(children: nil)
            }
        })

    }
    
    static func mockChildren() -> [Child] {
        let child1 = Child(dob: NSDate(timeIntervalSinceNow: (-1.0)*365*24*60*60), gender: Child.Gender.Female)
        let child2 = Child(dob: NSDate(timeIntervalSinceNow: (-1.0)*365*24*60*60), gender: Child.Gender.Male)
        let child3 = Child(dob: NSDate(timeIntervalSinceNow: (-1.0)*365*24*60*60), gender: Child.Gender.Female)
        
        return [child1, child2, child3]
    }
}