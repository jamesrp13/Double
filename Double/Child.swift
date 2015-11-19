//
//  Child.swift
//  Double
//
//  Created by James Pacheco on 11/18/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import Foundation

struct Child {
    enum Gender {
        case Male
        case Female
    }
    
    var dob: NSDate
    var gender: Gender
}