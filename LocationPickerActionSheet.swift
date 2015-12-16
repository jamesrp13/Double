//
//  LocationPickerActionSheet.swift
//  Double
//
//  Created by James Pacheco on 12/14/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class LocationPickerActionSheet: UIView, UITextFieldDelegate {
    
    let doneButton = UIButton()
    let useLocationButton = UIButton()
    let orLabel = UILabel()
    let zipTextField = UITextField()
    
    convenience init(parent: UIViewController, doneActionSelector: Selector, locationActionSelector: Selector) {
        self.init()
        let phoneFrame = parent.view.frame
        
        let stackView = UIStackView(arrangedSubviews: [useLocationButton, orLabel, zipTextField, doneButton])
        stackView.axis = .Vertical
        
        //Create background view and properties
        self.frame = CGRect(x: 0.0, y: 0.0, width: phoneFrame.width, height: phoneFrame.height/3.5)
        self.backgroundColor = .whiteColor()
        self.addSubview(stackView)
        stackView.frame = self.frame
        stackView.distribution = .FillEqually
        stackView.alignment = .Fill
        
        //useLocationButton properties
        useLocationButton.frame.size.height = zipTextField.frame.height * 2
        useLocationButton.setTitle("Use current location", forState: .Normal)
        useLocationButton.backgroundColor = .blueColor()
        useLocationButton.setTitleColor(.whiteColor(), forState: .Normal)
        useLocationButton.addTarget(parent, action: locationActionSelector, forControlEvents: .TouchUpInside)
        
        //orLabel properties
        orLabel.text = "OR"
        
        //zipTextField properties
        zipTextField.placeholder = "Enter your zip code"
        zipTextField.delegate = self
        
        //Add properties to doneButton
        doneButton.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: 30)
        doneButton.setTitle("Done", forState: .Normal)
        doneButton.backgroundColor = .whiteColor()
        doneButton.setTitleColor(.blueColor(), forState: .Normal)
        doneButton.addTarget(parent, action: doneActionSelector, forControlEvents: .TouchUpInside)
        
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}