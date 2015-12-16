//
//  PersonController.swift
//  Double
//
//  Created by James Pacheco on 11/19/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

class PersonController {
    
    static func fetchPeopleDataForProfileIdentifier(profileIdentifier: String, completion: (peopleDictionary: [String:AnyObject]?) -> Void) {
        FirebaseController.base.childByAppendingPath("people").queryOrderedByChild("profileIdentifier").queryEqualToValue(profileIdentifier).observeSingleEventOfType(.Value, withBlock: { (data) -> Void in
            if let peopleDictionaries = data.value as? [String: AnyObject] {
                
                completion(peopleDictionary: peopleDictionaries)
            } else {
                completion(peopleDictionary: nil)
            }
        })
    }
    
    static func savePeople(var people: (Person, Person)) {
        people.0.save()
        people.1.save()
    }
    
    static func deletePeople(people: (Person, Person)) {
        people.0.delete()
        people.1.delete()
    }
    
    static func mockPeople() -> [Person] {
        let person1 = Person(name: "James", dob: NSDate(timeIntervalSince1970: 0.0), gender: Person.Gender.Male)
        let person2 = Person(name: "Jodie", dob: NSDate(timeIntervalSince1970: 0.0), gender: Person.Gender.Female)
        let person3 = Person(name: "Seth", dob: NSDate(timeIntervalSince1970: 0.0), gender: Person.Gender.Male)
        let person4 = Person(name: "Cyd", dob: NSDate(timeIntervalSince1970: 0.0), gender: Person.Gender.Female)
        
        return [person1, person2, person3, person4]
    }
    
    static func ageInYearsFromBirthday(birthday: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Year, fromDate: birthday, toDate: NSDate(), options: .MatchFirst)
        return components.year
    }
    
    static func ageInMonthsFromBirthday(birthday: NSDate) -> Int {
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.components(.Month, fromDate: birthday, toDate: NSDate(), options: .MatchFirst)
        return components.month
    }
}