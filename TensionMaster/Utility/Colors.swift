//
//  Colors.swift
//  TensionMaster
//
//  Created by Nikolay Markov on 2/6/19.
//  Copyright © 2019 Nikolay Markov. All rights reserved.
//

import UIKit

extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int, a: CGFloat = 1.0) {
        self.init(red: CGFloat(red) / 255.0,
                  green: CGFloat(green) / 255.0,
                  blue: CGFloat(blue) / 255.0,
                  alpha: a)
    }
    
    convenience init(rgb: Int, a: CGFloat = 1.0) {
        self.init(red: (rgb >> 16) & 0xFF,
                  green: (rgb >> 8) & 0xFF,
                  blue: rgb & 0xFF,
                  a: a)
    }
    
}

extension UIColor {
    
    class var backgroundDark: UIColor {
        return UIColor(rgb: 0x2A3652)
    }
    
    class var backgroundLight: UIColor {
        return UIColor(rgb: 0x3F4A6D)
    }
    
    class var circleStart: UIColor {
        return UIColor(rgb: 0x947FEE)
    }
    
    class var circleEnd: UIColor {
        return UIColor(rgb: 0xF74A8E)
    }
    
    class var accent: UIColor {
        return UIColor(rgb: 0xC17AD3)
    }
    
    class var soundIndicator: UIColor {
        return UIColor.circleStart
    }
    
    class var mainText: UIColor {
        return UIColor.white
    }
    
    class var secondaryText: UIColor {
        return UIColor(rgb: 0xFFFFFF, a: CGFloat(0xBB) / 0xFF)
    }

}
