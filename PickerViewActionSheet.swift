//
//  PickerViewActionSheet.swift
//  Double
//
//  Created by James Pacheco on 12/16/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class PickerViewActionSheet: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let doneButton = UIButton()
    let pickerView = UIPickerView()
    
    convenience init(parent: UIViewController, doneActionSelector: Selector) {
        self.init()
        let phoneFrame = parent.view.frame
        
        //Create background view and properties
        self.frame = CGRect(x: 0.0, y: 0.0, width: phoneFrame.width, height: phoneFrame.height/3.5)
        self.backgroundColor = .whiteColor()
        self.addSubview(pickerView)
        self.addSubview(doneButton)
        
        //Create date picker and add properties
        pickerView.frame = CGRect(x: 0.0, y: phoneFrame.height*0.1, width: self.frame.width, height: self.frame.height*0.9)
        pickerView.center = self.center
        pickerView.dataSource = self
        pickerView.delegate = self
        
        //Add properties to doneButton
        doneButton.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: 30)
        doneButton.setTitle("Done", forState: .Normal)
        doneButton.backgroundColor = .whiteColor()
        doneButton.setTitleColor(.blueColor(), forState: .Normal)
        doneButton.addTarget(parent, action: doneActionSelector, forControlEvents: .TouchUpInside)
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 26
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if row == 0 {
            return ""
        } else {
            return String(row)
        }
    }
}