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
    private let kProfileIdentifier = "profileIdenifier"
    
    enum Gender {
        case Male
        case Female
    }
    
    var dob: NSDate
    var gender: Gender
    var profileIdentifier: String?
    
    // FirebaseType attributes and failable initializer
    var identifier: String?
    var jsonValue: [String: AnyObject] {
        var json: [String: AnyObject] = [kDob: dob, kGender: gender.hashValue]
        if let profileIdentifier = profileIdentifier {
            json.updateValue(profileIdentifier, forKey: kProfileIdentifier)
        }
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
        self.profileIdentifier = json[kProfileIdentifier] as? String
        self.identifier = identifier
    }
    
    // Standard initializer
    init(dob: NSDate, gender: Gender, profileIdentifier: String? = nil, identifier: String? = nil) {
        self.dob = dob
        self.gender = gender
        self.profileIdentifier = profileIdentifier
        self.identifier = identifier
    }
}