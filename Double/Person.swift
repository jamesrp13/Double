//
//  Person.swift
//  Double
//
//  Created by James Pacheco on 11/18/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

struct Person: FirebaseType {
    
    private let kName = "name"
    private let kDob = "dob"
    private let kGender = "gender"
    
    enum Gender {
        case Male
        case Female
    }
    
    let name: String
    let dob: NSDate
    let gender: Gender
    
    // FirebaseType attributes
    var identifier: String?
    
    var endpoint: String {
        return "people"
    }
    
    var jsonValue: [String: AnyObject] {
        let json: [String: AnyObject] = [kName: name, kDob: dob, kGender: gender.hashValue]
        return json
    }
    
    init(name: String, dob: NSDate, gender: Gender) {
        self.name = name
        self.dob = dob
        self.gender = gender
    }
    
    init?(json: [String : AnyObject], identifier: String) {
        guard let name = json[kName] as? String,
            let dob = json[kDob] as? NSDate,
            let gender = json[kGender] as? Gender else {return nil}
        
        self.name = name
        self.dob = dob
        self.gender = gender
    }
    
    
}