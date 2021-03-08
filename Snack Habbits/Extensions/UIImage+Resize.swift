//
//  UIImage+Resize.swift
//  Snack Habbits
//
//  Created by Jony Tucci on 3/7/21.
//  Copyright © 2021 Jony Tucci. All rights reserved.
//

import Foundation
import UIKit

extension UIImage {
    func resizedImage(newSize: CGSize) -> UIImage {
        // Guard newSize is different
        guard self.size != newSize else { return self }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
    
}
