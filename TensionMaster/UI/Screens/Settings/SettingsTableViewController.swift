//
//  SettingsTableViewController.swift
//  TensionMaster
//
//  Created by Nikolay Markov on 10/28/18.
//  Copyright © 2018 Nikolay Markov. All rights reserved.
//

import UIKit
import MessageUI

class SettingsTableViewController: UITableViewController {
    
    @IBOutlet var modeLabel: UILabel!

    // Racquet section.
    @IBOutlet var headSizeCell: UITableViewCell!
    @IBOutlet var headSizeValueLabel: UILabel!
    @IBOutlet var headSizePickerCell: UITableViewCell!
    @IBOutlet var headSizePicker: UIPickerView!
    @IBOutlet var headSizePickerMediator: HeadSizePickerMediator!
    
    @IBOutlet var tensionUnitsCell: UITableViewCell!
    @IBOutlet var tensionUnitsValueLabel: UILabel!
    @IBOutlet var tensionUnitsPickerCell: UITableViewCell!
    @IBOutlet var tensionUnitsPicker: UIPickerView!
    @IBOutlet var tensionUnitsPickerMediator: TensionUnitPickerMediator!
    
    @IBOutlet var openingSizeCell: UITableViewCell!
    @IBOutlet var openingSizeValueLabel: UILabel!
    
    @IBOutlet var stringPatternCell: UITableViewCell!
    @IBOutlet var stringPatternValueLabel: UILabel!
    @IBOutlet var stringPatternPickerCell: UITableViewCell!
    @IBOutlet var stringPatternPicker: UIPickerView!
    @IBOutlet var stringPatternPickerMediator: StringPatternPickerMediator!
    
    // String section.
    @IBOutlet var stringerStyleCell: UITableViewCell!
    @IBOutlet var stringerStyleValueLabel: UILabel!
    @IBOutlet var stringerStylePickerCell: UITableViewCell!
    @IBOutlet var stringerStylePicker: UIPickerView!
    @IBOutlet var stringerStylePickerMediator: StringerStylePickerMediator!
    
    @IBOutlet var hybridStringingCell: UITableViewCell!
    @IBOutlet var hybridStringingSwitch: UISwitch!
    
    @IBOutlet var stringDiameterCell: UITableViewCell!
    @IBOutlet var stringDiameterLabel: UILabel!
    @IBOutlet var stringDiameterValueLabel: UILabel!
    @IBOutlet var stringDiameterPickerCell: UITableViewCell!
    @IBOutlet var stringDiameterPicker: UIPickerView!
    @IBOutlet var stringDiameterPickerMediator: StringDiameterPickerMediator!
    
    @IBOutlet var stringTypeCell: UITableViewCell!
    @IBOutlet var stringTypeLabel: UILabel!
    @IBOutlet var stringTypeValueLabel: UILabel!
    
    @IBOutlet var crossStringDiameterCell: UITableViewCell!
    @IBOutlet var crossStringDiameterValueLabel: UILabel!
    @IBOutlet var crossStringDiameterPickerCell: UITableViewCell!
    @IBOutlet var crossStringDiameterPicker: UIPickerView!
    @IBOutlet var crossStringDiameterPickerMediator: StringDiameterPickerMediator!
    
    @IBOutlet var crossStringTypeCell: UITableViewCell!
    @IBOutlet var crossStringTypeValueLabel: UILabel!
    
    // About section.
    @IBOutlet var versionLabel: UILabel!
    
    var expandedPickerCell: UITableViewCell?
    // Keep track of options picker table view controllers.
    weak var stringOpeningSizePickerTable: OptionsPickerTableViewController?
    weak var stringTypePickerTable: OptionsPickerTableViewController?
    weak var crossStringTypePickerTable: OptionsPickerTableViewController?
    
    lazy var versionString: String = {
        var fullVersion = ""
        if let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String {
            fullVersion = "\(version)"
        }
        if let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String {
            fullVersion += "(\(build))"
        }
        return fullVersion
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        versionLabel.text = versionString
        tableView.backgroundColor = UIColor.backgroundDark
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load only the selected mode since this is the only thing that can change outside this screen.
        modeLabel.text = "\(Settings.shared.measureMode.rawValue)"
        // Load settings data.
        reloadSettings()
    }
    
    // MARK: - Segue Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let optionsPicker = segue.destination as? OptionsPickerTableViewController {
            let settings = Settings.shared
            var title: String?
            let options: [OptionsSection]
            switch segue.identifier {
            case "StringOpeningSizePicking":
                title = "String Opening Size"
                stringOpeningSizePickerTable = optionsPicker
                let footer = """
                    Every racquet model has different density of the strings in the center of the stringbed. Measure with a ruler the distance "a" between 2 neighbouring main strings and the distance  "b" between 2 neighbouring  cross strings in millimetres. Calculate the area "S=a.b" of one string opening in mm². Choose your String opening size:
                    """
                options = [OptionsSection(headerText: nil,
                                          footerText: footer,
                                          rows: OpeningSize.allOptions(selected: settings.openingSize))]
            case "TypePicking":
                title = settings.hybridStringing ? "Main String Type" : "String Type"
                stringTypePickerTable = optionsPicker
                options = [OptionsSection(headerText: nil,
                                          footerText: nil,
                                          rows: StringType.allOptions(selected: settings.stringType))]
            case "CrossTypePicking":
                title = "Cross String Type"
                crossStringTypePickerTable = optionsPicker
                options = [OptionsSection(headerText: nil,
                                          footerText: nil,
                                          rows: StringType.allOptions(selected: settings.crossStringType))]
            default:
                options = []
            }
            optionsPicker.title = title
            optionsPicker.options = options
            optionsPicker.delegate = self
        }
    }
    
    // MARK: - Private Methods
    private func reloadSettings() {
        let settings = Settings.shared
        // Selected mode.
        modeLabel.text = "\(settings.measureMode.rawValue)"
        // Head size.
        headSizePickerMediator.reloadSelections()
        headSizeValueLabel.text = "\(Int(settings.headSize)) \(settings.headSizeUnit.rawValue)"
        // Opening size.
        openingSizeValueLabel.text = settings.openingSize.rawValue
        // String pattern.
        stringPatternPickerMediator.reloadSelections()
        stringPatternValueLabel.text = settings.stringPattern.rawValue
        // Stringer's style.
        stringerStylePickerMediator.reloadSelections()
        stringerStyleValueLabel.text = settings.stringerStyle.rawValue
        // Hybrid stringng.
        hybridStringingSwitch.isOn = settings.hybridStringing
        if settings.hybridStringing {
            stringDiameterLabel.text = "Main Thickness"
            stringTypeLabel.text = "Main Type"
        } else {
            stringDiameterLabel.text = "String Thickness"
            stringTypeLabel.text = "String Type"
        }
        // String diameter
        stringDiameterPickerMediator.reloadSelections()
        stringDiameterValueLabel.text = "\(settings.formattedStringDiameter) mm"
        // String type
        stringTypeValueLabel.text = settings.stringType.rawValue
        // Cross string diameter
        crossStringDiameterPickerMediator.cross = true
        crossStringDiameterPickerMediator.reloadSelections()
        crossStringDiameterValueLabel.text = "\(settings.formattedCrossStringDiameter) mm"
        // Cross string type
        crossStringTypeValueLabel.text = settings.crossStringType.rawValue
        // Tension unit
        tensionUnitsPickerMediator.reloadSelections()
        tensionUnitsValueLabel.text = settings.tensionUnit.rawValue
    }

    // MARK: - UITableViewDelegate
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if Settings.shared.hybridStringing == false {
            switch indexPath {
            case [1, 6], [1, 7], [1, 8]:
                return 0
            default:
                break
            }
        }
        let expandedHeight = CGFloat(160)
        let normalHeight = CGFloat(44)
        switch indexPath {
        case [0, 1]:
            return expandedPickerCell == headSizePickerCell ? expandedHeight : 0
        case [0, 3]:
            return expandedPickerCell == tensionUnitsPickerCell ? expandedHeight : 0
        case [0, 6]:
            return expandedPickerCell == stringPatternPickerCell ? expandedHeight : 0
        case [1, 1]:
            return expandedPickerCell == stringerStylePickerCell ? expandedHeight : 0
        case [1, 4]:
            return expandedPickerCell == stringDiameterPickerCell ? expandedHeight : 0
        case [1, 7]:
            return expandedPickerCell == crossStringDiameterPickerCell ? expandedHeight : 0
        default:
            return normalHeight
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedCell = tableView.cellForRow(at: indexPath) else { return }
        tableView.deselectRow(at: indexPath, animated: true)
        // Racquet or String section.
        if indexPath.section == 0 || indexPath.section == 1 {
            var correspondingPickerCell: UITableViewCell?
            switch selectedCell {
            case headSizeCell:
                correspondingPickerCell = headSizePickerCell
            case stringDiameterCell:
                correspondingPickerCell = stringDiameterPickerCell
            case crossStringDiameterCell:
                correspondingPickerCell = crossStringDiameterPickerCell
            case tensionUnitsCell:
                correspondingPickerCell = tensionUnitsPickerCell
            case stringPatternCell:
                correspondingPickerCell = stringPatternPickerCell
            case stringerStyleCell:
                correspondingPickerCell = stringerStylePickerCell
            default:
                break
            }
            
            // Collapse or open a picker.
            if expandedPickerCell == correspondingPickerCell {
                expandedPickerCell = nil
            } else {
                expandedPickerCell = correspondingPickerCell
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        } else {
            // The rest of the cells.
            switch indexPath {
            case [3, 0]:    // Instructions.
                instructionsPressed()
            case [3, 1]:    // Video.
                videoPressed()
            case [4, 0]:    // Share.
                sharePressed()
            case [4, 1]:    // Feedback.
                feedbackPressed()
            case [4, 2]:    // Privacy Policy.
                privacyPolicyPressed()
            default:
                break
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let headerView = view as? UITableViewHeaderFooterView {
            headerView.textLabel?.textColor = UIColor.accent
        }
    }

}

// MARK: - Handle Actions - Private
private extension SettingsTableViewController {
    
    @IBAction func hybridStringingValueChanged(control: UISwitch) {
        Settings.shared.hybridStringing = control.isOn
        if control.isOn {
            stringDiameterLabel.text = "Main Thickness"
            stringTypeLabel.text = "Main Type"
        } else {
            stringDiameterLabel.text = "String Thickness"
            stringTypeLabel.text = "String Type"
            if expandedPickerCell == crossStringDiameterPickerCell {
                expandedPickerCell = nil
            }
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func instructionsPressed() {
        // Present alert with instructions.
        let message = """
                        ∙ For best results use the app in places with less noise!

                        ∙ The user has to learn how to produce the proper ringing sound CLOSE (2 to 10 cm) and IN FRONT of the phone microphone. Find the microphone which uses single, very small hole either at the TOP or at the BOTTOM of the phone.

                        ∙ REMOVE the dampener - if you have.

                        ∙ Do not touch the strings with your fingers while measuring.

                        ∙ Tap the racquet strings VERY GENTLY ANYWHERE  several times every 1 or 2 sec. with ANY STIFF object. KEEP the resonating RINGING strings CLOSE (2 to 10 cm) and IN FRONT OF the phone microphone. The best way is with a pen or pencil, or use another racquet, fingernails, etc. It is shown well in the YouTube video https://youtu.be/PNTyjG7jr98 provided for TennisTension mobile app, Google Play Store or on www.tennistension.app

                        ∙ To receive the exact momentous string tension, define all the necessary racquet and string parameters. If you don't know some of them, default average values are taken for the calculations or the last values that the user put it in.

                        ∙ TennisTension measures the average tension between main and cross strings of the racquet. For example, if a racquet is strung 25/24 kg, the measurement result will be 24.5 kg.

                        ∙ String tensions of hybrid strings could be measured as well. In this case, define the parameters of both main and cross strings.

                        ∙ The error of the measurement result is less than 0.2 kg when the accurate racquet, string, and stringer/stringing machine parameters are set.

                        ∙ A Calibration for the app is provided in the case you want to cope COMPLETELY and SIMULTANEOUSLY with ALL specific characteristics of your PERSONAL racquet and string model. In this case, use a TRUSTED stringer.
                    """
        let alert = UIAlertController(title: "Instructions", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func videoPressed() {
        guard let url = URL(string: "https://www.youtube.com/watch?v=sucBKQ-4KaE&feature=youtu.be") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
    func sharePressed() {
//        guard let url = URL(string: "https://play.google.com/store/apps/details?id=com.racquetbuddy") else {
//            return
//        }
        let text = "Hey check out my app at: http://itunes.apple.com/app/id1441997912"
        let shareVC = UIActivityViewController(activityItems: [text/*, url*/], applicationActivities: nil)
        present(shareVC, animated: true)
    }
    
    func feedbackPressed() {
        guard MFMailComposeViewController.canSendMail() else {
            let alert = UIAlertController(title: "Cannot send mail",
                                          message: "You are currently unable to send mails. Please check if your mail client is properly configured and try again.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            present(alert, animated: true)
            return
        }
        
        let composeVC = MFMailComposeViewController()
        composeVC.mailComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.setToRecipients(["tennistension@gmail.com"])
        composeVC.setSubject("Tension Master")
        
        // Present the view controller modally.
        self.present(composeVC, animated: true, completion: nil)
    }
    
    func privacyPolicyPressed() {
        guard let url = URL(string: "https://craftsoftlabs.com/tensionmaster-privacypolicy/") else { return }
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
    }
    
}

// MARK: - MFMailComposeViewControllerDelegate
extension SettingsTableViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        // Dismiss the mail compose view controller.
        controller.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - PickerMediatorDelegate
extension SettingsTableViewController: PickerMediatorDelegate {
    
    func pickerMediator(_ pickerMediator: PickerMediator,
                        forPicker picker: UIPickerView,
                        didSelectRow row: Int,
                        inComponent component: Int) {
        let selectedValue = pickerMediator.selectedValue(component: 0)
        // Head size picker.
        if picker == headSizePicker {
            let selectedUnit = pickerMediator.selectedValue(component: 1)
            // Save it to settings.
            if let headSize = Double(selectedValue) {
                Settings.shared.headSize = headSize
            } else {
                assertionFailure("Cannot convert string to Double: \(selectedValue)")
            }
            if let headSizeUnit = SizeUnit(rawValue: selectedUnit) {
                Settings.shared.headSizeUnit = headSizeUnit
            } else {
                assertionFailure("Cannot convert string to SizeUnit: \(selectedUnit)")
            }
            // Display it.
            headSizeValueLabel.text = "\(selectedValue) \(selectedUnit)"
        } else if picker == stringDiameterPicker {
            // String diameter picker.
            if let stringDiameter = Double(selectedValue) {
                Settings.shared.stringDiameter = stringDiameter
            } else {
                assertionFailure("Cannot convert string to Double: \(selectedValue)")
            }
            // Display it.
            stringDiameterValueLabel.text = "\(selectedValue) mm"
        } else if picker == crossStringDiameterPicker {
            // Cross string diameter picker.
            if let stringDiameter = Double(selectedValue) {
                Settings.shared.crossStringDiameter = stringDiameter
            } else {
                assertionFailure("Cannot convert string to Double: \(selectedValue)")
            }
            // Display it.
            crossStringDiameterValueLabel.text = "\(selectedValue) mm"
        } else if picker == tensionUnitsPicker {
            // Tension units picker.
            if let tensionUnit = TensionUnit(rawValue: selectedValue) {
                Settings.shared.tensionUnit = tensionUnit
            } else {
                assertionFailure("Cannot convert string to TensionUnit: \(selectedValue)")
            }
            // Display it.
            tensionUnitsValueLabel.text = selectedValue
        } else if picker == stringPatternPicker {
            // String pattern picker.
            if let stringPattern = StringPattern(rawValue: selectedValue) {
                Settings.shared.stringPattern = stringPattern
            } else {
                assertionFailure("Cannot convert string to StringPattern: \(selectedValue)")
            }
            // Display it.
            stringPatternValueLabel.text = selectedValue
        } else if picker == stringerStylePicker {
            // Stringer's style picker.
            if let stringerStyle = StringerStyle(rawValue: selectedValue) {
                Settings.shared.stringerStyle = stringerStyle
            } else {
                assertionFailure("Cannot convert string to StringerStyle: \(selectedValue)")
            }
            // Display it.
            stringerStyleValueLabel.text = selectedValue
        }
    }
    
}

// MARK: - OptionsPickerTableViewControllerDelegate
extension SettingsTableViewController: OptionsPickerTableViewControllerDelegate {
    
    func optionsPicker(_ picker: OptionsPickerTableViewController, didSelectOptionAt indexPath: IndexPath) {
        let settings = Settings.shared
        let value = picker.options[indexPath].text
        if picker == stringOpeningSizePickerTable {
            if let openingSize = OpeningSize(rawValue: value) {
                settings.openingSize = openingSize
            } else {
                assertionFailure("Cannot convert string to OpeningSize: \(value)")
            }
            // Display it.
            openingSizeValueLabel.text = value
        } else if picker == stringTypePickerTable {
            if let stringType = StringType(rawValue: value) {
                settings.stringType = stringType
            } else {
                assertionFailure("Cannot convert string to StringType: \(value)")
            }
            // Display it.
            stringTypeValueLabel.text = value
        } else if picker == crossStringTypePickerTable {
            if let stringType = StringType(rawValue: value) {
                settings.crossStringType = stringType
            } else {
                assertionFailure("Cannot convert string to StringType: \(value)")
            }
            // Display it.
            crossStringTypeValueLabel.text = value
        }
    }
    
}
