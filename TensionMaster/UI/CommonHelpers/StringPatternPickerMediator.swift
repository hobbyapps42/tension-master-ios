//
//  StringPatternPickerMediator.swift
//  TensionMaster
//
//  Created by Nikolay Markov on 4/21/19.
//  Copyright © 2019 Nikolay Markov. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class StringPatternPickerMediator: PickerMediator, ActionSheetCustomPickerDelegate {
    
    lazy var values = StringPattern.allRepresentations
    
    override func value(row: Int, component: Int) -> String {
        return values[row]
    }
    
    override func reloadSelections() {
        if let index = values.firstIndex(of: Settings.shared.stringPattern.rawValue) {
            pickerView.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    func actionSheetPicker(_ actionSheetPicker: AbstractActionSheetPicker!, configurePickerView pickerView: UIPickerView!) {
        self.pickerView = pickerView
        reloadSelections()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return values.count
    }
    
}
