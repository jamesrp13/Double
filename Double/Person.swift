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
    private let kAbout = "about"
    private let kProfileIdentifier = "profileIdentifier"
    
    enum Gender: String {
        case Male = "M"
        case Female = "F"
    }
    
    let name: String
    let dob: NSDate
    let gender: Gender
    let about: String?
    var profileIdentifier: String?
    
    var age: Int {
        return Int(dob.timeIntervalSinceNow) * (-1) / (365*24*60*60)
    }
    
    // FirebaseType attributes and failable initializer
    var identifier: String?
    
    var endpoint: String {
        return "people"
    }
    
    var jsonValue: [String: AnyObject] {
        var json: [String: AnyObject] = [kName: name, kDob: dob.timeIntervalSince1970, kGender: gender.rawValue]
        
        if let profileIdentifier = profileIdentifier {
            json.updateValue(profileIdentifier, forKey: kProfileIdentifier)
        }
        return json
    }
    
    init?(json: [String : AnyObject], identifier: String) {
        guard let name = json[kName] as? String,
            let dobTimeInverval = json[kDob] as? NSTimeInterval,
            let genderRawValue = json[kGender] as? String,
            let gender = Gender(rawValue: genderRawValue) else {return nil}
        
        self.name = name
        self.dob = NSDate(timeIntervalSince1970: dobTimeInverval)
        self.gender = gender
        self.profileIdentifier = json[kProfileIdentifier] as? String
        self.identifier = identifier
        self.about = json[kAbout] as? String
    }
    
    // Standard initializer
    init(name: String, dob: NSDate, gender: Gender, about: String? = nil, profileIdentifier: String? = nil, identifier: String? = nil) {
        self.name = name
        self.dob = dob
        self.gender = gender
        self.about = about
        self.profileIdentifier = profileIdentifier
    }
    
}