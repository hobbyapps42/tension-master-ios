//
//  MeasureViewController.swift
//  TensionMaster
//
//  Created by Nikolay Markov on 10/29/18.
//  Copyright © 2018 Nikolay Markov. All rights reserved.
//

import UIKit
import AudioKitUI
import ActionSheetPicker_3_0

class MeasureViewController: UIViewController {
    
    @IBOutlet private var circleView: UIGradientView!
    @IBOutlet private var measureModeLabel: UILabel!
    @IBOutlet private var measureAdjustmentLabel: UILabel!
    @IBOutlet private var tensionNumberLabel: UILabel!
    @IBOutlet private var tensionUnitLabel: UILabel!
    
    @IBOutlet private var headSizeContainer: UIGradientView!
    @IBOutlet private var headSizeLabel: UILabel!
    @IBOutlet private var headSizeValueLabel: UILabel!
    @IBOutlet private var stringerStyleContainer: UIGradientView!
    @IBOutlet private var stringerStyleLabel: UILabel!
    @IBOutlet private var stringerStyleValueLabel: UILabel!
    @IBOutlet private var stringPatternContainer: UIGradientView!
    @IBOutlet private var stringPatternLabel: UILabel!
    @IBOutlet private var stringPatternValueLabel: UILabel!
    @IBOutlet private var openingSizeContainer: UIGradientView!
    @IBOutlet private var openingSizeLabel: UILabel!
    @IBOutlet private var openingSizeValueLabel: UILabel!
    @IBOutlet private var stringDiameterContainer: UIGradientView!
    @IBOutlet private var stringDiameterLabel: UILabel!
    @IBOutlet private var stringDiameterValueLabel: UILabel!
    @IBOutlet private var stringTypeContainer: UIGradientView!
    @IBOutlet private var stringTypeLabel: UILabel!
    @IBOutlet private var stringTypeValueLabel: UILabel!
    @IBOutlet private var crossStringDiameterContainer: UIGradientView!
    @IBOutlet private var crossStringDiameterLabel: UILabel!
    @IBOutlet private var crossStringDiameterValueLabel: UILabel!
    @IBOutlet private var crossStringTypeContainer: UIGradientView!
    @IBOutlet private var crossStringTypeLabel: UILabel!
    @IBOutlet private var crossStringTypeValueLabel: UILabel!
    
    @IBOutlet private var extendedInfoContainerHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var crossContainerHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet private var plotView: EZAudioPlot!
    private var plot: AKNodeOutputPlot?
    
    private var lastUpdateSample: SoundAnalyzerSample?
    private var clearWorkItem: DispatchWorkItem?
    
    private var headSizePickerMediator = HeadSizePickerMediator()
    private var tensionUnitsPickerMediator = TensionUnitPickerMediator()
    private var stringPatternPickerMediator = StringPatternPickerMediator()
    private var stringerStylePickerMediator = StringerStylePickerMediator()
    private var stringDiameterPickerMediator = StringDiameterPickerMediator()
    private var crossStringDiameterPickerMediator = StringDiameterPickerMediator()
    
    // Keep track of options picker table view controllers.
    private weak var stringOpeningSizePickerTable: OptionsPickerTableViewController?
    private weak var stringTypePickerTable: OptionsPickerTableViewController?
    private weak var crossStringTypePickerTable: OptionsPickerTableViewController?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupMediators()
        setupGestures()
        setupPlot()
        brand()
        
        SoundAnalyzer.shared.start { started in
            print("Stared - \(started)")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // Update with the last sample in case the settings are changed.
        if let sample = lastUpdateSample {
            update(sample: sample)
        }
        updateAdditionalInfo()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        SoundAnalyzer.shared.delegate = self
        plot?.resume()
        checkFirstRun()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        if SoundAnalyzer.shared.delegate === self {
            SoundAnalyzer.shared.delegate = nil
        }
        plot?.pause()
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    // MARK: - Private Methods
    private func setupMediators() {
        headSizePickerMediator.delegate = self
        tensionUnitsPickerMediator.delegate = self
        stringPatternPickerMediator.delegate = self
        stringerStylePickerMediator.delegate = self
        stringDiameterPickerMediator.delegate = self
        crossStringDiameterPickerMediator.delegate = self
        crossStringDiameterPickerMediator.cross = true
    }
    
    private func setupGestures() {
        headSizeContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped(_:))))
        stringerStyleContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped(_:))))
        stringPatternContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped(_:))))
        openingSizeContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped(_:))))
        stringDiameterContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped(_:))))
        stringTypeContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped(_:))))
        crossStringDiameterContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped(_:))))
        crossStringTypeContainer.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(containerTapped(_:))))
    }
    
    @objc private func containerTapped(_ recognizer: UITapGestureRecognizer) {
        guard let recognizedView = recognizer.view else { return }
        var actionSheetPicker: ActionSheetCustomPicker?
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch recognizedView {
        case headSizeContainer:
            actionSheetPicker = ActionSheetCustomPicker(title: "Head Size",
                                                        delegate: headSizePickerMediator,
                                                        showCancelButton: false,
                                                        origin: self.view)
        case stringerStyleContainer:
            actionSheetPicker = ActionSheetCustomPicker(title: "Stringing Machine",
                                                        delegate: stringerStylePickerMediator,
                                                        showCancelButton: false,
                                                        origin: self.view)
        case stringPatternContainer:
            actionSheetPicker = ActionSheetCustomPicker(title: "String Pattern",
                                                        delegate: stringPatternPickerMediator,
                                                        showCancelButton: false,
                                                        origin: self.view)
        case openingSizeContainer:
            let optionsPickerTable = storyboard.instantiateViewController(withIdentifier: "OptionsPickerTableVC") as! OptionsPickerTableViewController
            let footer = """
                    Every racquet model has different density of the strings in the center of the stringbed. Measure with a ruler the distance "a" between 2 neighbouring main strings and the distance  "b" between 2 neighbouring  cross strings in millimetres. Calculate the area "S=a.b" of one string opening in mm². Choose your String opening size:
                    """
            optionsPickerTable.title = "String Opening Size"
            optionsPickerTable.delegate = self
            optionsPickerTable.options = [OptionsSection(headerText: nil,
                                      footerText: footer,
                                      rows: OpeningSize.allOptions(selected: Settings.shared.openingSize))]
            navigationController?.pushViewController(optionsPickerTable, animated: true)
            stringOpeningSizePickerTable = optionsPickerTable
        case stringDiameterContainer:
            let title = Settings.shared.hybridStringing ? "Main Thickness" : "String Thickness"
            actionSheetPicker = ActionSheetCustomPicker(title: title,
                                                        delegate: stringDiameterPickerMediator,
                                                        showCancelButton: false,
                                                        origin: self.view)
        case stringTypeContainer:
            let optionsPickerTable = storyboard.instantiateViewController(withIdentifier: "OptionsPickerTableVC") as! OptionsPickerTableViewController
            optionsPickerTable.title = Settings.shared.hybridStringing ? "Main String Type" : "String Type"
            optionsPickerTable.delegate = self
            optionsPickerTable.options = [OptionsSection(headerText: nil,
                                                         footerText: nil,
                                                         rows: StringType.allOptions(selected: Settings.shared.stringType))]
            navigationController?.pushViewController(optionsPickerTable, animated: true)
            stringTypePickerTable = optionsPickerTable
        case crossStringDiameterContainer:
            actionSheetPicker = ActionSheetCustomPicker(title: "Cross Thickness",
                                                        delegate: crossStringDiameterPickerMediator,
                                                        showCancelButton: false,
                                                        origin: self.view)
        case crossStringTypeContainer:
            let optionsPickerTable = storyboard.instantiateViewController(withIdentifier: "OptionsPickerTableVC") as! OptionsPickerTableViewController
            optionsPickerTable.title = "Cross String Type"
            optionsPickerTable.delegate = self
            optionsPickerTable.options = [OptionsSection(headerText: nil,
                                                         footerText: nil,
                                                         rows: StringType.allOptions(selected: Settings.shared.crossStringType))]
            navigationController?.pushViewController(optionsPickerTable, animated: true)
            crossStringTypePickerTable = optionsPickerTable
        default:
            break
        }
        if let picker = actionSheetPicker {
            picker.pickerBackgroundColor = UIColor.backgroundDark
            picker.toolbarBackgroundColor = UIColor.backgroundDark
            picker.toolbarButtonsColor = UIColor.accent
            picker.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.mainText]
            picker.show()
        }
    }
    
    private func brand() {
        if let gradientLayer = view.layer as? CAGradientLayer {
            gradientLayer.colors = [UIColor.backgroundDark.cgColor, UIColor.backgroundLight.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        }
        // Circle view.
        if let gradientLayer = circleView.layer as? CAGradientLayer {
            gradientLayer.colors = [UIColor.circleStart.cgColor, UIColor.circleEnd.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
            gradientLayer.cornerRadius = circleView.bounds.width / 2
        }
        // Labels.
        headSizeLabel.textColor = UIColor.accent
        stringerStyleLabel.textColor = UIColor.accent
        stringPatternLabel.textColor = UIColor.accent
        openingSizeLabel.textColor = UIColor.accent
        stringDiameterLabel.textColor = UIColor.accent
        stringTypeLabel.textColor = UIColor.accent
        crossStringDiameterLabel.textColor = UIColor.accent
        crossStringTypeLabel.textColor = UIColor.accent
        // Containers.
        let modifyContainerLayer: (CALayer) -> Void = { layer in
            guard let gradientLayer = layer as? CAGradientLayer else { return }
            gradientLayer.colors = [UIColor.backgroundLight.cgColor, UIColor.backgroundDark.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
            gradientLayer.cornerRadius = 16
            gradientLayer.shadowColor = UIColor.black.cgColor
            gradientLayer.shadowOffset = CGSize(width: -3, height: 3)
            gradientLayer.shadowOpacity = 0.3
        }
        modifyContainerLayer(headSizeContainer.layer)
        modifyContainerLayer(stringerStyleContainer.layer)
        modifyContainerLayer(stringPatternContainer.layer)
        modifyContainerLayer(openingSizeContainer.layer)
        modifyContainerLayer(stringDiameterContainer.layer)
        modifyContainerLayer(stringTypeContainer.layer)
        modifyContainerLayer(crossStringDiameterContainer.layer)
        modifyContainerLayer(crossStringTypeContainer.layer)
    }
    
    private func setupPlot() {
        let frame = CGRect(x: 0, y: -20, width: plotView.bounds.width, height: 60)
        let plot = AKNodeOutputPlot(SoundAnalyzer.shared.mic, frame: frame)
        plot.autoresizingMask = .flexibleWidth
        plot.plotType = .buffer
        plot.shouldFill = true
        plot.gain = 1.5 // This number is multiplied by amplitude.
        plot.color = UIColor.soundIndicator
        plot.backgroundColor = UIColor.clear
        plotView.addSubview(plot)
        self.plot = plot
    }
    
    private func update(sample: SoundAnalyzerSample) {
        lastUpdateSample = sample
        
        var tensionValue = sample.tensionNumber
        let settings = Settings.shared
        tensionValue += (settings.measureMode == .calibrated ? settings.tensionAdjustment : 0)
        tensionNumberLabel.text = String(format: "%0.1f", tensionValue)
    }
    
    private func update(adjustment: Double) {
        if adjustment > 0.0 {
            measureAdjustmentLabel.text = "(+\(String(format: "%0.1f", adjustment))\(Settings.shared.tensionUnit.rawValue))"
        } else {
            measureAdjustmentLabel.text = "(\(String(format: "%0.1f", adjustment))\(Settings.shared.tensionUnit.rawValue))"
        }
    }
    
    private func updateAdditionalInfo() {
        let settings = Settings.shared
        if settings.measureMode == .calibrated && settings.tensionAdjustment != 0.0 {
            measureModeLabel.isHidden = false
            measureModeLabel.text = "Calibrated"
            measureAdjustmentLabel.isHidden = false
            update(adjustment: settings.tensionAdjustment)
        } else {
            measureModeLabel.isHidden = true
            measureAdjustmentLabel.isHidden = true
        }
        tensionUnitLabel.text = settings.tensionUnit.rawValue
        stringerStyleValueLabel.text = settings.stringerStyle.rawValue
        stringPatternValueLabel.text = settings.stringPattern.rawValue
        openingSizeValueLabel.text = settings.openingSize.rawValue
        headSizeValueLabel.text = "\(Int(settings.headSize)) \(settings.headSizeUnit.rawValue)"
        stringDiameterValueLabel.text = "\(settings.formattedStringDiameter) mm"
        stringTypeValueLabel.text = settings.stringType.rawValue
        if settings.hybridStringing {
            extendedInfoContainerHeightConstraint.isActive = true
            crossContainerHeightConstraint.isActive = true
            crossStringDiameterContainer.isHidden = false
            crossStringTypeContainer.isHidden = false
            stringDiameterLabel.text = "Main Thickness"
            stringTypeLabel.text = "Main Type"
            crossStringDiameterLabel.text = "Cross Thickness"
            crossStringTypeLabel.text = "Cross Type"
            crossStringDiameterValueLabel.text = "\(settings.formattedCrossStringDiameter) mm"
            crossStringTypeValueLabel.text = settings.crossStringType.rawValue
        } else {
            extendedInfoContainerHeightConstraint.isActive = false
            crossContainerHeightConstraint.isActive = false
            crossStringDiameterContainer.isHidden = true
            crossStringTypeContainer.isHidden = true
            stringDiameterLabel.text = "String Thickness"
            stringTypeLabel.text = "String Type"
        }
    }
    
    private func checkFirstRun() {
        let defaults = UserDefaults.standard
        if defaults.bool(forKey: "firstRun") == false {
            // Show an information alert.
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
            // Save the first run is passed.
            defaults.set(true, forKey: "firstRun")
            defaults.synchronize()
        }
    }

}

// MARK: - SoundAnalyzerDelegate
extension MeasureViewController: SoundAnalyzerDelegate {
    
    func soundAnalyzerSample(_ sample: SoundAnalyzerSample) {
        if sample.isValid {
            clearWorkItem?.cancel()
            clearWorkItem = DispatchWorkItem { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.lastUpdateSample = nil
                strongSelf.tensionNumberLabel.text = "0"
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: clearWorkItem!)
            DispatchQueue.main.async { [weak self] in
                self?.update(sample: sample)
            }
        }
    }
    
}

// MARK: - PickerMediatorDelegate
extension MeasureViewController: PickerMediatorDelegate {
    
    func pickerMediator(_ pickerMediator: PickerMediator,
                        forPicker picker: UIPickerView,
                        didSelectRow row: Int,
                        inComponent component: Int) {
        let selectedValue = pickerMediator.selectedValue(component: 0)
        // Head size picker.
        if pickerMediator == headSizePickerMediator {
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
        } else if pickerMediator == stringDiameterPickerMediator {
            // String diameter picker.
            if let stringDiameter = Double(selectedValue) {
                Settings.shared.stringDiameter = stringDiameter
            } else {
                assertionFailure("Cannot convert string to Double: \(selectedValue)")
            }
            // Display it.
            stringDiameterValueLabel.text = "\(selectedValue) mm"
        } else if pickerMediator == crossStringDiameterPickerMediator {
            // Cross string diameter picker.
            if let stringDiameter = Double(selectedValue) {
                Settings.shared.crossStringDiameter = stringDiameter
            } else {
                assertionFailure("Cannot convert string to Double: \(selectedValue)")
            }
            // Display it.
            crossStringDiameterValueLabel.text = "\(selectedValue) mm"
        } else if pickerMediator == tensionUnitsPickerMediator {
            // Tension units picker.
            if let tensionUnit = TensionUnit(rawValue: selectedValue) {
                Settings.shared.tensionUnit = tensionUnit
            } else {
                assertionFailure("Cannot convert string to TensionUnit: \(selectedValue)")
            }
            // Display it.
            tensionUnitLabel.text = selectedValue
        } else if pickerMediator == stringPatternPickerMediator {
            // String pattern picker.
            if let stringPattern = StringPattern(rawValue: selectedValue) {
                Settings.shared.stringPattern = stringPattern
            } else {
                assertionFailure("Cannot convert string to StringPattern: \(selectedValue)")
            }
            // Display it.
            stringPatternValueLabel.text = selectedValue
        } else if pickerMediator == stringerStylePickerMediator {
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
extension MeasureViewController: OptionsPickerTableViewControllerDelegate {

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
