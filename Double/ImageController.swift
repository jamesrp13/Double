//
//  ImageController.swift
//  Double
//
//  Created by James Pacheco on 11/18/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class ImageController {
    
    private static let aspectRatio = CGFloat(2.0)/3.0
    private static let profileWidth = UIApplication.sharedApplication().windows.first?.frame.width
    private static let profileHeight = profileWidth!*aspectRatio
    
    static func uploadImage(image: UIImage, completion: (identifier: String?) -> Void) {
        if let base64Image = image.base64String {
            let base = FirebaseController.base.childByAppendingPath("images").childByAutoId()
            base.setValue(base64Image)
            completion(identifier: base.key)
        } else {
            completion(identifier: nil)
        }
        
    }
    
    static func replaceImage(image: UIImage, identifier: String, completion: (identifier: String?) -> Void) {
        if let base64Image = image.base64String {
            let base = FirebaseController.base.childByAppendingPath("images/\(identifier)")
            base.setValue(base64Image)
            completion(identifier: base.key)
        } else {
            completion(identifier: nil)
        }
    }
    
    static func deleteImage(identifier: String) {
        FirebaseController.base.childByAppendingPath("images").childByAppendingPath(identifier).removeValue()
    }
    
    static func imageForIdentifier(identifier: String, completion: (image: UIImage?) -> Void) {
        FirebaseController.dataAtEndpoint("/images/\(identifier)") { (data) -> Void in
            if let data = data as? String {
                let image = UIImage(base64String: data)
                completion(image: image)
            } else {
                completion(image: nil)
            }
        }
    }
    
    static func cropImageForProfiles(image: UIImage) -> UIImage {
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        var width = originalWidth
        var height = originalHeight * (3.0/2.0)
        let posX = CGFloat(0.0)
        let posY = CGFloat(0.0)
        if originalHeight < (originalWidth * 2.0/3.0) {
            height = originalHeight
            width = originalHeight * 3.0/2.0
        }

        let cropRectangle = CGRectMake(posX, posY, width, height)
        
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRectangle);
        return UIImage(CGImage: imageRef!, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
    }
    
    static func cropImageForCircle(image: UIImage) -> UIImage {
        let originalWidth  = image.size.width
        let originalHeight = image.size.height
        
        let posX = CGFloat(0.0) + (originalWidth - originalHeight) / 2
        let posY = CGFloat(0.0)
        
        let cropRectangle = CGRectMake(posX, posY, originalHeight, originalHeight)
        
        let imageRef = CGImageCreateWithImageInRect(image.CGImage, cropRectangle);
        return UIImage(CGImage: imageRef!, scale: UIScreen.mainScreen().scale, orientation: image.imageOrientation)
    }
    
    static func resizeForProfile(image: UIImage) -> UIImage {
        let width = profileWidth!
        let height = profileHeight
        let size = CGSize(width: width, height: height)
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
    
    static func resizeForCircle(image: UIImage) -> UIImage {
        let size = CGSize(width: 70, height: 70)
        let hasAlpha = false
        let scale: CGFloat = 0.0 // Automatically use scale factor of main screen
        
        UIGraphicsBeginImageContextWithOptions(size, !hasAlpha, scale)
        image.drawInRect(CGRect(origin: CGPointZero, size: size))
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return scaledImage
    }
}

extension UIImage {
    var base64String: String? {
        guard let data = UIImageJPEGRepresentation(self, 0.75) else {return nil}
        
        return data.base64EncodedStringWithOptions(.EncodingEndLineWithCarriageReturn)
    }
    
    convenience init?(base64String: String) {
        if let data = NSData(base64EncodedString: base64String, options: .IgnoreUnknownCharacters) {
            self.init(data: data)
        } else {
            return nil
        }
    }
    
}