//
//  PersonController.swift
//  Double
//
//  Created by James Pacheco on 11/19/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

class PersonController {
    
    static func fetchPeopleForProfileIdentifier(profileIdentifier: String, completion: (people: (Person, Person)?) -> Void) {
        FirebaseController.base.childByAppendingPath("people").queryOrderedByChild("profileIdentifier").queryEqualToValue(profileIdentifier).observeSingleEventOfType(.Value, withBlock: { (data) -> Void in
            if let peopleDictionaries = data.value as? [String: AnyObject] {
                let people = peopleDictionaries.flatMap({Person(json: $0.1 as! [String: AnyObject], identifier: $0.0)})
                //print (data.value)
                if people.count == 2 {
                    let peopleTuple = (people[0], people[1])
                    completion(people: peopleTuple)
                } else {
                    print("Looks like we don't have exactly two people matching this identifier: \(people)")
                }
            } else {
                completion(people: nil)
            }
        })
    }
    
    static func mockPeople() -> [Person] {
        let person1 = Person(name: "James", dob: NSDate(timeIntervalSince1970: 0.0), gender: Person.Gender.Male)
        let person2 = Person(name: "Jodie", dob: NSDate(timeIntervalSince1970: 0.0), gender: Person.Gender.Female)
        let person3 = Person(name: "Seth", dob: NSDate(timeIntervalSince1970: 0.0), gender: Person.Gender.Male)
        let person4 = Person(name: "Cyd", dob: NSDate(timeIntervalSince1970: 0.0), gender: Person.Gender.Female)
        
        return [person1, person2, person3, person4]
    }
}