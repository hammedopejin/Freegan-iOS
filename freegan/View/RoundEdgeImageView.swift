//
//  RoundEdgeView.swift
//  freegan
//
//  Created by Hammed opejin on 3/18/19.
//  Copyright © 2019 Hammed opejin. All rights reserved.
//

import UIKit

class RoundEdgeImageView: UIImageView {
    
    override func layoutSubviews() {
        layer.cornerRadius = self.frame.width / 8
        clipsToBounds = true
    }
}
