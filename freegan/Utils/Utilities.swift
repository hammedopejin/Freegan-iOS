//
//  Utilities.swift
//  freegan
//
//  Created by Hammed opejin on 1/9/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import Foundation
import Firebase

private let dateFormat = "yyyy-MM-dd"
private let dateFormatWithTime = "yyyy-MM-dd hh:mm:ss a"

func dateFormatter() -> DateFormatter {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormat
    
    return dateFormatter
}

func dateFormatterWithTime() -> DateFormatter {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = dateFormatWithTime
    
    return dateFormatter
}

func maskRoundedImage(image: UIImage, radius: Float) -> UIImage {
    
    let imageView: UIImageView = UIImageView(image: image)
    var layer: CALayer = CALayer()
    layer = imageView.layer
    
    layer.masksToBounds = true
    layer.cornerRadius = CGFloat(radius)
    
    UIGraphicsBeginImageContext(imageView.bounds.size)
    layer.render(in: UIGraphicsGetCurrentContext()!)
    let roundedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return roundedImage!
}

func imageFromData(pictureData: String, withBlock: (_ image: UIImage?) -> Void) {
    
    var image: UIImage?
    
    let decodedData = NSData(base64Encoded: pictureData, options: NSData.Base64DecodingOptions(rawValue: 0))
    
    image = UIImage(data: decodedData! as Data)
    
    withBlock(image)
}


func loadImage(imageUrl: String, image: @escaping(_ image: UIImage) -> Void){
    let ref = Storage.storage().reference(forURL: imageUrl)
    ref.getData(maxSize: 2 * 1024 * 1024, completion: { (data, error) in
        if error != nil {
            print("HAMMED: Unable to download image from Firebase storage \(error.debugDescription)")
        } else {
            print("HAMMED: Image downloaded from Firebase storage, goood newwwws")
            if let imgData = data {
                if let img = UIImage(data: imgData) {
                    image(img)
                    FeedVC.imageCache.setObject(img, forKey: imageUrl as NSString)
                }
            }
        }
    })
}

func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
    let size = image.size
    
    let widthRatio  = targetSize.width  / size.width
    let heightRatio = targetSize.height / size.height
    
    // Figure out what our orientation is, and use that to form the rectangle
    var newSize: CGSize
    if(widthRatio > heightRatio) {
        newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
    } else {
        newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
    }
    
    // This is the rect that we've calculated out and this is what is actually used below
    let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
    
    // Actually do the resizing to the rect using the ImageContext stuff
    UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
    image.draw(in: rect)
    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return newImage!
}
