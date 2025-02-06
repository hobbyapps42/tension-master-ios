//
//  PickerMediator.swift
//  TensionMaster
//
//  Created by Nikolay Markov on 10/28/18.
//  Copyright © 2018 Nikolay Markov. All rights reserved.
//

import UIKit

@objc protocol PickerMediatorDelegate: class {
    
    func pickerMediator(_ pickerMediator: PickerMediator,
                        forPicker picker: UIPickerView,
                        didSelectRow row: Int,
                        inComponent component: Int)
    
}

class PickerMediator: NSObject, UIPickerViewDelegate {
    
    @IBOutlet var pickerView: UIPickerView!
    @IBOutlet var delegate: PickerMediatorDelegate?
    
    // Override this method in subclasses.
    func value(row: Int, component: Int) -> String {
        assertionFailure("Override this method in subclasses!")
        return ""
    }
    
    func reloadSelections() {
        assertionFailure("Override this method in subclasses!")
    }
    
    func selectedValue(component: Int) -> String {
        return value(row: pickerView.selectedRow(inComponent: component), component: component)
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        return NSAttributedString(string: value(row: row, component: component),
                                  attributes: [NSAttributedString.Key.foregroundColor: UIColor.mainText])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.pickerMediator(self, forPicker: pickerView, didSelectRow: row, inComponent: component)
    }
    
}
