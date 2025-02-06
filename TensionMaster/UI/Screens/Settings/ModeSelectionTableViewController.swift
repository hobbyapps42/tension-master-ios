//
//  ModeSelectionTableViewController.swift
//  TensionMaster
//
//  Created by Nikolay Markov on 11/5/18.
//  Copyright © 2018 Nikolay Markov. All rights reserved.
//

import UIKit

class ModeSelectionTableViewController: UITableViewController {
    
    lazy var settings = Settings.shared
    
    var fabricModeCell: UITableViewCell?
    var personalModeCell: UITableViewCell?
    var adjustCell: AdjustTableViewCell?
    
    private var lastUpdateSample: SoundAnalyzerSample?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = UIColor.backgroundDark
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        startMeasuring()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        stopMeasuring()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        if settings.measureMode == .fabric {
            return 1
        } else {
            return 2
        }
    }
    
//    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        if section == 0 {
//            return 0
//        } else {
//            return 120
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
//        if section == 0 {
//            return nil
//        } else {
//            let label = UILabel(frame: CGRect.zero)
//            label.numberOfLines = 0
//            label.text = """
//            Calibration:
//            1. Take a racquet with known string tension.
//            2. Enter this racquet and its string parameters in the settings.
//            3. Tap the string close to the microphone.
//            4. After the Factory measurement is done push the Calibrate button and enter the known tension.
//            """
//            return label
//        }
//    }
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        if section == 0 {
            return nil
        } else {
            return """
            Calibration:
               1. Take a racquet with known string tension.
               2. Enter this racquet and its string parameters in the settings.
               3. Tap the string close to the microphone.
               4. After the Factory measurement is done push the Calibrate button and enter the known tension.
            """
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 2
        } else {
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return 44
        } else {
            return 320
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell
        switch indexPath {
        case [0, 0]:    // Fabric mode.
            cell = tableView.dequeueReusableCell(withIdentifier: "ModeCell", for: indexPath)
            fabricModeCell = cell
        case [0, 1]:    // Personal mode.
            cell = tableView.dequeueReusableCell(withIdentifier: "ModeCell", for: indexPath)
            personalModeCell = cell
        default:
            cell = tableView.dequeueReusableCell(withIdentifier: "AdjustCell", for: indexPath)
            adjustCell = cell as? AdjustTableViewCell
            adjustCell?.delegate = self
        }
        update(cell: cell, forIndexPath: indexPath)
        return cell
    }
    
    func update(cell: UITableViewCell?, forIndexPath indexPath: IndexPath) {
        
        switch indexPath {
        case [0, 0]:    // Factory mode.
            cell?.textLabel?.text = "Off"
            cell?.accessoryType = settings.measureMode == .fabric ? .checkmark : .none
        case [0, 1]:    // Personal mode.
            cell?.textLabel?.text = "On"
            cell?.accessoryType = settings.measureMode == .calibrated ? .checkmark : .none
        default:
            if let adjustCell = cell as? AdjustTableViewCell {
                adjustCell.update(adjustment: settings.tensionAdjustment)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            tableView.deselectRow(at: indexPath, animated: true)
            tableView.beginUpdates()
            if indexPath.row == 0, settings.measureMode == .calibrated {
                settings.measureMode = .fabric
                update(cell: fabricModeCell, forIndexPath: [0, 0])
                update(cell: personalModeCell, forIndexPath: [0, 1])
                tableView.deleteSections(IndexSet(integer: 1), with: .fade)
            } else if indexPath.row == 1, settings.measureMode == .fabric {
                settings.measureMode = .calibrated
                update(cell: fabricModeCell, forIndexPath: [0, 0])
                update(cell: personalModeCell, forIndexPath: [0, 1])
                tableView.insertSections(IndexSet(integer: 1), with: .fade)
            }
            tableView.endUpdates()
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = UIColor.accent
        }
    }

}

// MARK: - Measuring Methods
private extension ModeSelectionTableViewController {
    
    func startMeasuring() {
        SoundAnalyzer.shared.delegate = self
        adjustCell?.resumePlot()
    }
    
    func stopMeasuring() {
        if SoundAnalyzer.shared.delegate === self {
            SoundAnalyzer.shared.delegate = nil
        }
        adjustCell?.pausePlot()
    }
    
}

// MARK: - AdjustTableViewCellDelegate
extension ModeSelectionTableViewController: AdjustTableViewCellDelegate {
    
    func adjustCellSelectAdjust(_ cell: AdjustTableViewCell) {
        var tensionString: String
        let measuredTension = lastUpdateSample?.tensionNumber ?? 0.0
        if measuredTension > 0.0 {
            tensionString = String(format: "%0.1f", measuredTension)
        } else {
            tensionString = "0.0"
        }
        let message = "\nFactory measurement is \(tensionString)."
        let alert = UIAlertController(title: "Calibration", message: message, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter the preknown tension"
            textField.keyboardType = .decimalPad
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            self.startMeasuring()   // Continue to measure after the dialog is closed.
        }))
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
            if let text = alert.textFields?.first?.text?.replacingOccurrences(of: ",", with: "."), let tension = Double(text) {
                self.settings.tensionAdjustment = tension - measuredTension
                self.tableView.reloadData()
                // Update the adjust cell also after changing the tension adjustment.
                if let sample = self.lastUpdateSample {
                    self.adjustCell?.update(sample: sample)
                }
            }
            self.startMeasuring()   // Continue to measure after the dialog is closed.
        }))
        // While the alert is presented stop measuring the tension.
        stopMeasuring()
        present(alert, animated: true)
    }
    
}

// MARK: - SoundAnalyzerDelegate
extension ModeSelectionTableViewController: SoundAnalyzerDelegate {
    
    func soundAnalyzerSample(_ sample: SoundAnalyzerSample) {
        if adjustCell != nil && sample.isValid {
            DispatchQueue.main.async { [weak self] in
                self?.lastUpdateSample = sample
                self?.adjustCell?.update(sample: sample)
            }
        }
    }
    
}
