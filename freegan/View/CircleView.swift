//
//  CircleView.swift
//  freegan
//
//  Created by Hammed opejin on 3/19/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit

class CircleView: UIImageView {
    
    override func layoutSubviews() {
        layer.cornerRadius = self.frame.width / 2
        clipsToBounds = true
    }
}
