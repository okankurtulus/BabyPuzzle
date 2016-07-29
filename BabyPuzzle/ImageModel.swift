//
//  ImageModel.swift
//  BabyPuzzle
//
//  Created by Okan Kurtulus on 28/07/16.
//  Copyright © 2016 Okan Kurtulus. All rights reserved.
//

import Foundation
import UIKit

class ImageModel: BaseModel {
    
    static func cropToBounds(imageView: UIImageView, rect: CGRect) -> UIImage {
        let image : UIImage = imageView.image!
        
        print("Image size:\(image.size)")
        
        
        let xMultiplier = image.size.width / imageView.frame.size.width
        let yMultiplier = image.size.height / imageView.frame.size.height
        let x = rect.origin.x * xMultiplier
        let y = rect.origin.y * yMultiplier
        let width = rect.size.width * xMultiplier
        let height = rect.size.height * yMultiplier
        let cropRect = CGRectMake(x, y, width, height)
        let imageRef: CGImageRef = CGImageCreateWithImageInRect(image.CGImage, cropRect)!        
        let croppedImage: UIImage = UIImage(CGImage: imageRef, scale: image.scale, orientation: image.imageOrientation)
        return croppedImage
    }
}