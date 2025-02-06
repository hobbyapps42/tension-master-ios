//
//  HeadSizePickerMediator.swift
//  TensionMaster
//
//  Created by Nikolay Markov on 10/28/18.
//  Copyright © 2018 Nikolay Markov. All rights reserved.
//

import UIKit
import ActionSheetPicker_3_0

enum HeadSizePickerMediatorMode {
    case inches
    case cm
}

class HeadSizePickerMediator: PickerMediator, ActionSheetCustomPickerDelegate {

    lazy var headSizesInches = Array(Settings.shared.headSizeInchRange).map(Double.init)
    lazy var headSizesCm = Array(Settings.shared.headSizeCmRange).map(Double.init)
    var headSizes: [Double] {
        switch mode {
        case .inches: return headSizesInches
        case .cm: return headSizesCm
        }
    }
    lazy var headSizeUnits = SizeUnit.allRepresentations
    var mode = HeadSizePickerMediatorMode.inches
    // Applying a new mode animated.
    private func applyMode(_ mode: HeadSizePickerMediatorMode) {
        if self.mode != mode {
            self.mode = mode
            pickerView.reloadComponent(0)
            pickerView.selectRow(headSizes.count / 2, inComponent: 0, animated: true)
        }
    }
    
    override func value(row: Int, component: Int) -> String {
        if component == 0 {
            return "\(Int(headSizes[row]))"
        } else {
            return headSizeUnits[row]
        }
    }
    
    override func reloadSelections() {
        if let index = headSizeUnits.firstIndex(of: Settings.shared.headSizeUnit.rawValue) {
            mode = (index == 0) ? .inches : .cm
            pickerView.selectRow(index, inComponent: 1, animated: false)
        }
        if let index = headSizes.firstIndex(of: Settings.shared.headSize) {
            pickerView.selectRow(index, inComponent: 0, animated: false)
        }
    }
    
    func actionSheetPicker(_ actionSheetPicker: AbstractActionSheetPicker!, configurePickerView pickerView: UIPickerView!) {
        self.pickerView = pickerView
        reloadSelections()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return component == 0 ? headSizes.count : headSizeUnits.count
    }
    
    override func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 1 {
            if row == 0 {
                applyMode(.inches)
            } else {
                applyMode(.cm)
            }
        }
        super.pickerView(pickerView, didSelectRow: row, inComponent: component)
    }
    
}
