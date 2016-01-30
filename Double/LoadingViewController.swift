//
//  LoadingViewController.swift
//  Double
//
//  Created by James Pacheco on 1/29/16.
//  Copyright © 2016 James Pacheco. All rights reserved.
//

import UIKit

class LoadingViewController: UIViewController {

    @IBOutlet weak var loadingImageView: UIImageView!
    
    var rotation: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        startLoadingWheelAnimation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func startLoadingWheelAnimation() {
        rotation += CGFloat(M_PI / 3.0)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.loadingImageView.transform = CGAffineTransformMakeRotation(self.rotation)
            NSTimer.scheduledTimerWithTimeInterval(1.0/12.0, target: self, selector: "startLoadingWheelAnimation", userInfo: nil, repeats: false)
        }

    }

}
