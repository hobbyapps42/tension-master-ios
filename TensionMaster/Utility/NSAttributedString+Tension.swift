
//
//  NSAttributedString+Tension.swift
//  TensionMaster
//
//  Created by Nikolay Markov on 11/12/18.
//  Copyright © 2018 Nikolay Markov. All rights reserved.
//

import Foundation
import UIKit

extension NSAttributedString {
    
    class func tensionString(_ string: String, font: UIFont) -> NSAttributedString {
        let attrString = NSMutableAttributedString(string: string)
        let range = NSMakeRange(string.count - 1, 1)
        // Adjust the font.
        let newFont = font.withSize(font.pointSize / 2)
        attrString.addAttribute(.font, value: newFont, range: range)
        return NSAttributedString(attributedString: attrString) // Make it immutable.
    }
    
}
