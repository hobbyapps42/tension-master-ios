//
//  Settings.swift
//  TensionMaster
//
//  Created by Nikolay Markov on 10/31/18.
//  Copyright © 2018 Nikolay Markov. All rights reserved.
//

import Foundation

// Calibratio feature /Experimental/.
enum MeasureMode: String {
    case fabric = "Off"
    case calibrated = "On"
}

enum StringType: String {
    case heavyPolyester = "Heavy Polyester"
    case polyester = "Avarage Polyester"
    case lightPolyester = "Light Polyester"
    case heavySynthetic = "Multifilament"
    case synthetic = "Avarage Synthetic"
    case lightSynthetic = "Light Synthetic"
    case naturalGut = "Natural Gut"
    var details: String? {
        switch self {
        case .heavyPolyester: return "less stretchable; higher density ingredients"
        case .polyester: return nil
        case .lightPolyester: return "more stretchable; lower density ingredients"
        case .heavySynthetic: return nil
        case .synthetic: return nil
        case .lightSynthetic: return "more stretchable; lower density ingredients"
        case .naturalGut: return nil
        }
    }
    var coefficient: Double {
        switch self {
        case .heavyPolyester: return 1.38
        case .polyester: return 1.35
        case .lightPolyester: return 1.32
        case .heavySynthetic: return 1.16
        case .synthetic: return 1.12
        case .lightSynthetic: return 1.08
        case .naturalGut: return 1.28
        }
    }
    static func allOptions(selected: StringType) -> [OptionsRow] {
        return [OptionsRow(text: heavyPolyester.rawValue,
                           additionalText: heavyPolyester.details,
                           selected: selected == heavyPolyester ? true : false),
                OptionsRow(text: polyester.rawValue,
                           additionalText: polyester.details,
                           selected: selected == polyester ? true : false),
                OptionsRow(text: lightPolyester.rawValue,
                           additionalText: lightPolyester.details,
                           selected: selected == lightPolyester ? true : false),
                OptionsRow(text: heavySynthetic.rawValue,
                           additionalText: heavySynthetic.details,
                           selected: selected == heavySynthetic ? true : false),
                OptionsRow(text: synthetic.rawValue,
                           additionalText: synthetic.details,
                           selected: selected == synthetic ? true : false),
                OptionsRow(text: lightSynthetic.rawValue,
                           additionalText: lightSynthetic.details,
                           selected: selected == lightSynthetic ? true : false),
                OptionsRow(text: naturalGut.rawValue,
                           additionalText: naturalGut.details,
                           selected: selected == naturalGut ? true : false)]
    }
}

enum SizeUnit: String {
    case inch = "in²"
    case cm = "cm²"
    static var allRepresentations: [String] {
        return [inch.rawValue, cm.rawValue]
    }
}

enum TensionUnit: String {
    case lb
    case kg
    static var allRepresentations: [String] {
        return [lb.rawValue, kg.rawValue]
    }
}

enum OpeningSize: String {
    case XS = "XS"
    case S = "S"
    case M = "M"
    case L = "L"
    case XL = "XL"
    var details: String {
        switch self {
        case .XS: return "88 mm² or less"
        case .S: return "89-104 mm²"
        case .M: return "105-120 mm²"
        case .L: return "121-136 mm²"
        case .XL: return "137 mm² or more"
        }
    }
    var coefficient: Double {
        switch self {
        case .XS: return 1.03
        case .S: return 1.015
        case .M: return 1
        case .L: return 0.985
        case .XL: return 0.97
        }
    }
    static func allOptions(selected: OpeningSize) -> [OptionsRow] {
        return [OptionsRow(text: XS.rawValue, additionalText: XS.details, selected: selected == XS ? true : false),
                OptionsRow(text: S.rawValue, additionalText: S.details, selected: selected == S ? true : false),
                OptionsRow(text: M.rawValue, additionalText: M.details, selected: selected == M ? true : false),
                OptionsRow(text: L.rawValue, additionalText: L.details, selected: selected == L ? true : false),
                OptionsRow(text: XL.rawValue, additionalText: XL.details, selected: selected == XL ? true : false)]
    }
}

enum StringPattern: String {
    case extremelyOpen = "very open"
    case x14x16 = "14x16"
    case x16x16 = "16x16"
    case x16x17 = "16x17"
    case x16x18 = "16x18"
    case x16x19 = "16x19"
    case x16x20 = "16x20"
    case x18x17 = "18x17"
    case x18x18 = "18x18"
    case x18x19 = "18x19"
    case x18x20 = "18x20"
    case x18x21 = "18x21"
    var coefficient: Double {
        switch self {
        case .extremelyOpen: return 0.985
        case .x14x16: return 0.990
        case .x16x16: return 0.995
        case .x16x17: return 0.997
        case .x16x18: return 0.998
        case .x16x19: return 1
        case .x16x20: return 1.005
        case .x18x17: return 1.005
        case .x18x18: return 1.008
        case .x18x19: return 1.010
        case .x18x20: return 1.013
        case .x18x21: return 1.015
        }
    }
    static var allRepresentations: [String] {
        return [extremelyOpen.rawValue,
                x14x16.rawValue,
                x16x16.rawValue,
                x16x17.rawValue,
                x16x18.rawValue,
                x16x19.rawValue,
                x16x20.rawValue,
                x18x17.rawValue,
                x18x18.rawValue,
                x18x19.rawValue,
                x18x20.rawValue,
                x18x21.rawValue]
    }
}

enum StringerStyle: String {
    case veryTight = "very tight"
    case tighter = "tight"
    case normal = "normal"
    case looser = "loose"
    case veryLoose = "very loose"
    static var allRepresentations: [String] {
        return [veryTight.rawValue,
                tighter.rawValue,
                normal.rawValue,
                looser.rawValue,
                veryLoose.rawValue]
    }
    var coefficient: Double {
        switch self {
        case .veryTight: return 0.85
        case .tighter: return 0.90
        case .normal: return 0.95
        case .looser: return 1
        case .veryLoose: return 1.08
        }
    }
}

private struct SettingsHolder {
    var measureMode: MeasureMode = .fabric
    var headSizeUnit: SizeUnit = .inch
    var headSize: Double = 100   // inches   (70..130) inches - (500..800) cm
    var hybridStringing = false
    var stringDiameter: Double = 1.25   // mm   (1.00..1.50) mm
    var stringType: StringType = .polyester
    var crossStringDiameter: Double = 1.25   // mm   (1.00..1.50) mm
    var crossStringType: StringType = .polyester
    var tensionUnit: TensionUnit = .kg
    var tensionAdjustment: Double = 0.0
    var openingSize: OpeningSize = .M
    var stringPattern: StringPattern = .x16x19
    var stringerStyle: StringerStyle = .normal
}

private struct Keys {
    static let measureMode = "measureModeKey"
    static let headSizeUnit = "headSizeUnitKey"
    static let headSize = "headSizeKey"
    static let hybridStringing = "hybridStringingKey"
    static let stringDiameter = "stringDiameterKey"
    static let stringType = "stringTypeKey"
    static let openingSize = "openingSizeKey"
    static let stringPattern = "stringPatternKey"
    static let stringerStyle = "stringerStyleKey"
    static let crossStringDiameter = "crossStringDiameterKey"
    static let crossStringType = "crossStringTypeKey"
    static let tensionUnit = "tensionUnitKey"
    static let tensionAdjustment = "tensionAdjustmentKey"
}

class Settings {
    
    lazy private var settingsHolder = SettingsHolder()
    static let shared = Settings()
    
    let headSizeInchRange = 70...130    // inches
    let headSizeCmRange = 500...800     // cm
    let stringDiameterStride = stride(from: 1.0, through: 1.5, by: 0.01)    // mm
    let stringDiameterFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 2
        formatter.maximumFractionDigits = 2
        formatter.decimalSeparator = "."
        return formatter
    }()
    
    var measureMode: MeasureMode {
        get {
            return settingsHolder.measureMode
        }
        set {
            settingsHolder.measureMode = newValue
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.measureMode)
        }
    }
    var headSizeUnit: SizeUnit {
        get {
            return settingsHolder.headSizeUnit
        }
        set {
            settingsHolder.headSizeUnit = newValue
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.headSizeUnit)
        }
    }
    var headSize: Double {
        get {
            return settingsHolder.headSize
        }
        set {
            settingsHolder.headSize = newValue
            UserDefaults.standard.set(newValue, forKey: Keys.headSize)
        }
    }
    var hybridStringing: Bool {
        get {
            return settingsHolder.hybridStringing
        }
        set {
            settingsHolder.hybridStringing = newValue
            UserDefaults.standard.set(newValue, forKey: Keys.hybridStringing)
        }
    }
    // 1st string.
    var stringDiameter: Double {
        get {
            return settingsHolder.stringDiameter
        }
        set {
            settingsHolder.stringDiameter = newValue
            UserDefaults.standard.set(newValue, forKey: Keys.stringDiameter)
        }
    }
    var formattedStringDiameter: String {
        get {
            return stringDiameterFormatter.string(from: stringDiameter as NSNumber) ?? String(format: "%0.3f", stringDiameter)
        }
    }
    var stringType: StringType {
        get {
            return settingsHolder.stringType
        }
        set {
            settingsHolder.stringType = newValue
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.stringType)
        }
    }
    var openingSize: OpeningSize {
        get {
            return settingsHolder.openingSize
        }
        set {
            settingsHolder.openingSize = newValue
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.openingSize)
        }
    }
    var stringPattern: StringPattern {
        get {
            return settingsHolder.stringPattern
        }
        set {
            settingsHolder.stringPattern = newValue
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.stringPattern)
        }
    }
    var stringerStyle: StringerStyle {
        get {
            return settingsHolder.stringerStyle
        }
        set {
            settingsHolder.stringerStyle = newValue
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.stringerStyle)
        }
    }
    // Hybrid stringing (cross).
    var crossStringDiameter: Double {
        get {
            return settingsHolder.crossStringDiameter
        }
        set {
            settingsHolder.crossStringDiameter = newValue
            UserDefaults.standard.set(newValue, forKey: Keys.crossStringDiameter)
        }
    }
    var formattedCrossStringDiameter: String {
        get {
            return stringDiameterFormatter.string(from: crossStringDiameter as NSNumber) ?? String(format: "%0.3f", crossStringDiameter)
        }
    }
    var crossStringType: StringType {
        get {
            return settingsHolder.crossStringType
        }
        set {
            settingsHolder.crossStringType = newValue
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.crossStringType)
        }
    }
    // Tension.
    var tensionUnit: TensionUnit {
        get {
            return settingsHolder.tensionUnit
        }
        set {
            settingsHolder.tensionUnit = newValue
            UserDefaults.standard.set(newValue.rawValue, forKey: Keys.tensionUnit)
        }
    }
    var tensionAdjustment: Double {
        get {
            return settingsHolder.tensionAdjustment
        }
        set {
            settingsHolder.tensionAdjustment = newValue
            UserDefaults.standard.set(newValue, forKey: Keys.tensionAdjustment)
        }
    }
    
    init() {
        loadFromUserDefaults()
    }
    
    private func loadFromUserDefaults() {
        let defaults = UserDefaults.standard
        // Measure mode.
        if let value = defaults.string(forKey: Keys.measureMode), let measureMode = MeasureMode(rawValue: value) {
            settingsHolder.measureMode = measureMode
        }
        // Head size unit.
        if let value = defaults.string(forKey: Keys.headSizeUnit), let sizeUnit = SizeUnit(rawValue: value) {
            settingsHolder.headSizeUnit = sizeUnit
        }
        // Head size.
        if let value = defaults.object(forKey: Keys.headSize) as? Double {
            settingsHolder.headSize = value
        }
        // Hybrid stringing.
        if let value = defaults.object(forKey: Keys.hybridStringing) as? Bool {
            settingsHolder.hybridStringing = value
        }
        // String diameter.
        if let value = defaults.object(forKey: Keys.stringDiameter) as? Double {
            settingsHolder.stringDiameter = value
        }
        // String type.
        if let value = defaults.string(forKey: Keys.stringType), let stringType = StringType(rawValue: value) {
            settingsHolder.stringType = stringType
        }
        // String opoening size.
        if let value = defaults.string(forKey: Keys.openingSize), let openingSize = OpeningSize(rawValue: value) {
            settingsHolder.openingSize = openingSize
        }
        // String pattern.
        if let value = defaults.string(forKey: Keys.stringPattern), let stringPattern = StringPattern(rawValue: value) {
            settingsHolder.stringPattern = stringPattern
        }
        // Stringer's style.
        if let value = defaults.string(forKey: Keys.stringerStyle), let stringerStyle = StringerStyle(rawValue: value) {
            settingsHolder.stringerStyle = stringerStyle
        }
        // Cross String diameter.
        if let value = defaults.object(forKey: Keys.crossStringDiameter) as? Double {
            settingsHolder.crossStringDiameter = value
        }
        // Cross String type.
        if let value = defaults.string(forKey: Keys.crossStringType), let stringType = StringType(rawValue: value) {
            settingsHolder.crossStringType = stringType
        }
        // Tension units.
        if let value = defaults.string(forKey: Keys.tensionUnit), let tensionUnit = TensionUnit(rawValue: value) {
            settingsHolder.tensionUnit = tensionUnit
        }
        // Tension adjustment.
        if let value = defaults.object(forKey: Keys.tensionAdjustment) as? Double {
            settingsHolder.tensionAdjustment = value
        }
    }
    
}
