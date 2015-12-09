//
//  DatePickerActionSheet.swift
//  Double
//
//  Created by James Pacheco on 12/8/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class DatePickerActionSheet: UIView {
    
    let doneButton = UIButton()
    let datePicker = UIDatePicker()
    
    convenience init(parent: UIViewController, doneActionSelector: Selector) {
        self.init()
        let phoneFrame = parent.view.frame
        
        //Create background view and properties
        self.frame = CGRect(x: 0.0, y: 0.0, width: phoneFrame.width, height: phoneFrame.height/3.5)
        self.backgroundColor = .whiteColor()
        self.addSubview(datePicker)
        self.addSubview(doneButton)
        
        //Create date picker and add properties
        datePicker.frame = CGRect(x: 0.0, y: phoneFrame.height*0.1, width: self.frame.width, height: self.frame.height*0.9)
        datePicker.datePickerMode = .Date
        datePicker.center = self.center
        
        //Add properties to doneButton
        doneButton.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: 30)
        doneButton.setTitle("Done", forState: .Normal)
        doneButton.backgroundColor = .whiteColor()
        doneButton.setTitleColor(.blueColor(), forState: .Normal)
        doneButton.addTarget(parent, action: doneActionSelector, forControlEvents: .TouchUpInside)
    }
}