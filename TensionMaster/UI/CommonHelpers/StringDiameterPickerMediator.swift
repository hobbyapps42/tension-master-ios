//
//  StringDiameterPickerMediator.swift
//  TensionMaster
//
//  Created by Nikolay Markov on 10/31/18.
//  Copyright © 2018 Nikolay Markov. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class StringDiameterPickerMediator: PickerMediator, ActionSheetCustomPickerDelegate {
    
    lazy var stringDiameters = Array(Settings.shared.stringDiameterStride)
    var cross = false
    
    override func value(row: Int, component: Int) -> String {
        let diameter = stringDiameters[row]
        return Settings.shared.stringDiameterFormatter.string(from: diameter as NSNumber) ?? String(format: "%0.3f", diameter)
    }
    
    override func reloadSelections() {
        let diameter = cross ? Settings.shared.crossStringDiameter : Settings.shared.stringDiameter
        if let index = stringDiameters.firstIndex(of: diameter) {
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
        return stringDiameters.count
    }
    
}
