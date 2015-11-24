//
//  ChildController.swift
//  Double
//
//  Created by James Pacheco on 11/19/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

class ChildController {
    
    static func fetchChildrenDataForProfileIdentifier(profileIdentifier: String, completion: (childrenDictionary: [String: AnyObject]?) -> Void) {
        FirebaseController.base.childByAppendingPath("children").queryOrderedByChild("profileIdentifier").queryEqualToValue(profileIdentifier).observeSingleEventOfType(.Value, withBlock: { (data) -> Void in
            if let childrenDictionaries = data.value as? [String: AnyObject] {
                    completion(childrenDictionary: childrenDictionaries)
            } else {
                completion(childrenDictionary: nil)
            }
        })

    }
    
    static func saveChildren(children: [Child]?) {
        if let children = children {
            for var child in children {
                child.save()
            }
        }
    }
    
    static func deleteChildren(children: [Child]?) {
        if let children = children {
            for child in children {
                child.delete()
            }
        }
    }
    
    static func mockChildren() -> [Child] {
        let child1 = Child(dob: NSDate(timeIntervalSinceNow: (-1.0)*365*24*60*60), gender: Child.Gender.Female)
        let child2 = Child(dob: NSDate(timeIntervalSinceNow: (-1.0)*365*24*60*60), gender: Child.Gender.Male)
        let child3 = Child(dob: NSDate(timeIntervalSinceNow: (-1.0)*365*24*60*60), gender: Child.Gender.Female)
        
        return [child1, child2, child3]
    }
}