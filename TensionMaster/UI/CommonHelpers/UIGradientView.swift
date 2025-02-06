//
//  UIGradientView.swift
//  TensionMaster
//
//  Created by Nikolay Markov on 2/6/19.
//  Copyright © 2019 Nikolay Markov. All rights reserved.
//

import UIKit

class UIGradientView: UIView {
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
}
