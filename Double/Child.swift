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
    private let kProfileIdentifier = "profileIdentifier"
    
    enum Gender: String {
        case Male = "M"
        case Female = "F"
    }
    
    var dob: NSDate
    var gender: Gender
    var profileIdentifier: String?
    var age: Int {
        let calendar = NSCalendar.currentCalendar()
        let ageComponents = calendar.components(.Month, fromDate: dob, toDate: NSDate(), options: .MatchFirst)
        return ageComponents.month
    }
    
    // FirebaseType attributes and failable initializer
    var identifier: String?
    var jsonValue: [String: AnyObject] {
        var json: [String: AnyObject] = [kDob: dob, kGender: gender.rawValue]
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
            let genderRawValue = json[kGender] as? String,
            let gender = Gender(rawValue: genderRawValue) else {return nil}
        
        self.dob = dob
        self.gender = gender
        self.profileIdentifier = json[kProfileIdentifier] as? String
        self.identifier = identifier
    }
    
    // Standard initializer
    init(dob: NSDate, gender: Gender, profileIdentifier: String, identifier: String? = nil) {
        self.dob = dob
        self.gender = gender
        self.profileIdentifier = profileIdentifier
        self.identifier = identifier
    }
}