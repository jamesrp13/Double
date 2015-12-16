//
//  AboutCoupleActionSheet.swift
//  Double
//
//  Created by James Pacheco on 12/15/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class AboutCoupleActionSheet: UIView, UIPickerViewDataSource, UIPickerViewDelegate {
    
    let doneButton = UIButton()
    let relationshipStatusSegmentedControl = UISegmentedControl()
    let relationshipStartTextField = UITextField()
    let numberOfChildrenTextField = UITextField()
    var stackView = UIStackView()
    var kidNumberPicker = UIPickerView()
    
    var genericDatePicker: UIDatePicker? = nil
    
    var childrenStackView: UIStackView? {
        var views: [UIView] = []
        guard let numberAsText = numberOfChildrenTextField.text,
            let numberOfChildren = Int(numberAsText) where numberOfChildren > 0 else {return nil}
        for var i=0; i < numberOfChildren; i++ {
            let genderSegmentedControl = UISegmentedControl(items: ["Boy", "Girl"])
            let dobTextField = UITextField()
            let datePickerActionSheet = DatePickerActionSheet()
            dobTextField.inputView = datePickerActionSheet
            genericDatePicker = datePickerActionSheet.datePicker
            dobTextField.placeholder = "Date of birth"
            let horizontalStackView = UIStackView(arrangedSubviews: [genderSegmentedControl, dobTextField])
            views.append(horizontalStackView)
        }
        return UIStackView(arrangedSubviews: views)
    }
    
    convenience init(parent: UIViewController, doneActionSelector: Selector) {
        self.init()
        let phoneFrame = parent.view.frame
        
        let datePickerActionSheet = DatePickerActionSheet()
        genericDatePicker = datePickerActionSheet.datePicker
        
        self.stackView = UIStackView(arrangedSubviews: [relationshipStatusSegmentedControl, relationshipStartTextField, numberOfChildrenTextField])
        stackView.axis = .Vertical
        
        //Create background view and properties
        self.frame = CGRect(x: 0.0, y: 0.0, width: phoneFrame.width, height: phoneFrame.height*0.6)
        self.backgroundColor = .whiteColor()
        self.addSubview(stackView)
        stackView.frame = self.frame
        stackView.distribution = .FillEqually
        stackView.alignment = .Fill
        
        //relationshipStatus properties
        relationshipStatusSegmentedControl.setTitle("Dating", forSegmentAtIndex: 0)
        relationshipStatusSegmentedControl.setTitle("Engaged", forSegmentAtIndex: 1)
        relationshipStatusSegmentedControl.setTitle("Married", forSegmentAtIndex: 2)
        
        //relationshipStart properties
        relationshipStartTextField.placeholder = "Since when?"
        relationshipStartTextField.inputView = datePickerActionSheet
        
        //numberOfChildren properties
        numberOfChildrenTextField.placeholder = "Do you have any kids?"
        kidNumberPicker = UIPickerView()
        kidNumberPicker.dataSource = self
        kidNumberPicker.delegate = self
        numberOfChildrenTextField.inputView = kidNumberPicker
        numberOfChildrenTextField.inputAccessoryView = datePickerActionSheet.doneButton
        
        
        //Add properties to doneButton
        doneButton.frame = CGRect(x: 0.0, y: 0.0, width: self.frame.width, height: 30)
        doneButton.setTitle("Done", forState: .Normal)
        doneButton.backgroundColor = .whiteColor()
        doneButton.setTitleColor(.blueColor(), forState: .Normal)
        doneButton.addTarget(parent, action: doneActionSelector, forControlEvents: .TouchUpInside)
        
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 25
    }
    
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(row + 1)"
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
}