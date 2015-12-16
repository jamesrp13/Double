//
//  LocationPickerActionSheet.swift
//  Double
//
//  Created by James Pacheco on 12/14/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class LocationPickerActionSheet: UIView {
    
    let doneButton = UIButton()
    let useLocationButton = UIButton()
    let orLabel = UILabel()
    let useZipButton = UIButton()
    
    convenience init(parent: UIViewController, useZipSelector: Selector, useLocationSelector: Selector) {
        self.init()
        let phoneFrame = parent.view.frame
        
        let stackView = UIStackView(arrangedSubviews: [useLocationButton, orLabel, useZipButton])
        stackView.axis = .Vertical
        
        //Create background view and properties
        self.frame = CGRect(x: 0.0, y: 0.0, width: phoneFrame.width, height: phoneFrame.height/3.5)
        self.backgroundColor = .whiteColor()
        self.addSubview(stackView)
        stackView.frame = self.frame
        stackView.distribution = .FillEqually
        stackView.alignment = .Fill
        
        //useLocationButton properties
        useLocationButton.frame.size.height = 30.0
        useLocationButton.setTitle("Use current location", forState: .Normal)
        useLocationButton.backgroundColor = .blueColor()
        useLocationButton.setTitleColor(.whiteColor(), forState: .Normal)
        useLocationButton.addTarget(parent, action: useLocationSelector, forControlEvents: .TouchUpInside)
        
        //orLabel properties
        orLabel.text = "OR"
        
        //useZipButton properties
        useZipButton.frame.size.height = 30.0
        useZipButton.setTitle("Use zip code", forState: .Normal)
        useZipButton.backgroundColor = .blueColor()
        useZipButton.setTitleColor(.whiteColor(), forState: .Normal)
        useZipButton.addTarget(parent, action: useZipSelector, forControlEvents: .TouchUpInside)
        
    }
}