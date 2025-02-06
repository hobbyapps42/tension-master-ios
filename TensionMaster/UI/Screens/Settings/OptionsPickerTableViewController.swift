//
//  OptionsPickerTableViewController.swift
//  TensionMaster
//
//  Created by Nikolay Markov on 5/4/19.
//  Copyright © 2019 Nikolay Markov. All rights reserved.
//

import UIKit

struct OptionsRow {
    var text: String
    var additionalText: String?
    var selected = false
}

struct OptionsSection {
    var headerText: String?
    var footerText: String?
    var rows: [OptionsRow] = []
}

extension Array where Element == OptionsSection {
    
    subscript(indexPath: IndexPath) -> OptionsRow {
        get {
            return self[indexPath.section].rows[indexPath.row]
        }
        set {
            self[indexPath.section].rows[indexPath.row] = newValue
        }
    }
    
    var selectedIndexPath: IndexPath? {
        for (sectionIndex, section) in self.enumerated() {
            for (rowIndex, row) in section.rows.enumerated() {
                if row.selected {
                    return IndexPath(row: rowIndex, section: sectionIndex)
                }
            }
        }
        return nil
    }
    
}

protocol OptionsPickerTableViewControllerDelegate: class {
    
    func optionsPicker(_ picker: OptionsPickerTableViewController, didSelectOptionAt indexPath: IndexPath)
    
}

class OptionsPickerTableViewController: UITableViewController {
    
    var options: [OptionsSection]!
    weak var delegate: OptionsPickerTableViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
        tableView.backgroundColor = UIColor.backgroundDark
    }

    // MARK: - UITableViewDataSource
    override func numberOfSections(in tableView: UITableView) -> Int {
        return options.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return options[section].headerText
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return options[section].footerText
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return options[section].rows.count
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = UIColor.accent
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let footerView = view as? UITableViewHeaderFooterView {
            footerView.textLabel?.textColor = UIColor.accent
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = options[indexPath]
        let cell: UITableViewCell
        if row.additionalText != nil {
            cell = tableView.dequeueReusableCell(withIdentifier: "DetailedOption", for: indexPath)
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "SimpleOption", for: indexPath)
        }
        cell.textLabel?.text = row.text
        cell.detailTextLabel?.text = row.additionalText
        cell.accessoryType = row.selected ? .checkmark : .none

        return cell
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let prevSelected = options.selectedIndexPath
        if prevSelected == indexPath { return }
        if let indexPath = prevSelected {
            options[indexPath].selected = false
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.accessoryType = .none
            }
        }
        options[indexPath].selected = true
        if let cell = tableView.cellForRow(at: indexPath) {
            cell.accessoryType = .checkmark
        }
        delegate?.optionsPicker(self, didSelectOptionAt: indexPath)
    }

}
