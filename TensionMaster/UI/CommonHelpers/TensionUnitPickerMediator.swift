//
//  TensionUnitPickerMediator.swift
//  TensionMaster
//
//  Created by Nikolay Markov on 11/1/18.
//  Copyright © 2018 Nikolay Markov. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

class TensionUnitPickerMediator: PickerMediator, ActionSheetCustomPickerDelegate {
    
    lazy var tensionUnits = TensionUnit.allRepresentations
    
    override func value(row: Int, component: Int) -> String {
        return tensionUnits[row]
    }
    
    override func reloadSelections() {
        if let index = tensionUnits.firstIndex(of: Settings.shared.tensionUnit.rawValue) {
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
        return tensionUnits.count
    }
    
}
