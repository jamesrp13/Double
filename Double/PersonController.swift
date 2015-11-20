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
        
    }
    
    static func mockPeople() -> [Person] {
        let person1 = Person(name: "James", dob: NSDate(timeIntervalSince1970: 0.0), gender: Person.Gender.Male)
        let person2 = Person(name: "Jodie", dob: NSDate(timeIntervalSince1970: 0.0), gender: Person.Gender.Female)
        let person3 = Person(name: "Seth", dob: NSDate(timeIntervalSince1970: 0.0), gender: Person.Gender.Male)
        let person4 = Person(name: "Cyd", dob: NSDate(timeIntervalSince1970: 0.0), gender: Person.Gender.Female)
        
        return [person1, person2, person3, person4]
    }
}