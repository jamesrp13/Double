//
//  ImageController.swift
//  Double
//
//  Created by James Pacheco on 11/18/15.
//  Copyright © 2015 James Pacheco. All rights reserved.
//

import UIKit

class ImageController {
    
    static func uploadImage(image: UIImage, completion: (identifier: String?) -> Void) {
        if let base64Image = image.base64String {
            let base = FirebaseController.base.childByAppendingPath("images").childByAutoId()
            base.setValue(base64Image)
            completion(identifier: base.key)
        } else {
            completion(identifier: nil)
        }
        
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