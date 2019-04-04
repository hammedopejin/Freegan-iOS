//
//  PhotoCollectionViewCell.swift
//  freegan
//
//  Created by Hammed opejin on 1/24/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit

class PhotoCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setOpaqueBackground()
    }
    
}

private extension PhotoCollectionViewCell {
    static let defaultBackgroundColor = UIColor.groupTableViewBackground
    
    func setOpaqueBackground() {
        alpha = 1.0
        backgroundColor = PhotoCollectionViewCell.defaultBackgroundColor
        imageView.alpha = 1.0
        imageView.backgroundColor = PhotoCollectionViewCell.defaultBackgroundColor
    }
}
