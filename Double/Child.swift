//
//  Child.swift
//  Double
//
//  Created by James Pacheco on 11/18/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

struct Child: FirebaseType {
    
    private let kDob = "dob"
    private let kGender = "gender"
    
    enum Gender {
        case Male
        case Female
    }
    
    var dob: NSDate
    var gender: Gender
    
    // FirebaseType attributes and failable initializer
    var identifier: String?
    var jsonValue: [String: AnyObject] {
        let json: [String: AnyObject] = [kDob: dob, kGender: gender.hashValue]
        return json
    }
    var endpoint: String {
        return "children"
    }
    
    init?(json: [String : AnyObject], identifier: String) {
        guard let dob = json[kDob] as? NSDate,
            let gender = json[kGender] as? Gender else {return nil}
        
        self.dob = dob
        self.gender = gender
        self.identifier = identifier
    }
    
    // Standard initializer
    init(dob: NSDate, gender: Gender) {
        self.dob = dob
        self.gender = gender
    }
}