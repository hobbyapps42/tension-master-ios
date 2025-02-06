//
//  AdjustTableViewCell.swift
//  TensionMaster
//
//  Created by Nikolay Markov on 11/5/18.
//  Copyright © 2018 Nikolay Markov. All rights reserved.
//

import UIKit
import AudioKitUI

protocol AdjustTableViewCellDelegate: class {
    func adjustCellSelectAdjust(_ cell: AdjustTableViewCell)
}

class AdjustTableViewCell: DarkTableViewCell {
    
    @IBOutlet private var fabricModeCircle: UIGradientView!
    @IBOutlet private var fabricValueLabel: UILabel!
    @IBOutlet private var fabricUnitLabel: UILabel!
    
    @IBOutlet private var personalModeCircle: UIGradientView!
    @IBOutlet private var personalValueLabel: UILabel!
    @IBOutlet private var personalUnitLabel: UILabel!
    
    @IBOutlet private var adjustmentLabel: UILabel!
    @IBOutlet private var calibrateButton: UIButton!
    
    @IBOutlet private var plotView: EZAudioPlot!
    private var plot: AKNodeOutputPlot?
    
    weak var delegate: AdjustTableViewCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        calibrateButton.isEnabled = false
        // Fabric mode circle.
        if let gradientLayer = fabricModeCircle.layer as? CAGradientLayer {
            gradientLayer.colors = [UIColor.circleStart.cgColor, UIColor.circleEnd.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
            gradientLayer.cornerRadius = fabricModeCircle.bounds.width / 2
        }
        // Personal mode circle.
        if let gradientLayer = personalModeCircle.layer as? CAGradientLayer {
            gradientLayer.colors = [UIColor.circleStart.cgColor, UIColor.circleEnd.cgColor]
            gradientLayer.startPoint = CGPoint(x: 0, y: 1)
            gradientLayer.endPoint = CGPoint(x: 1, y: 0)
            gradientLayer.cornerRadius = personalModeCircle.bounds.width / 2
        }
        let tensionUnit = Settings.shared.tensionUnit
        fabricUnitLabel.text = tensionUnit.rawValue
        personalUnitLabel.text = tensionUnit.rawValue
        setupPlot()
        brand()
    }
    
    private func setupPlot() {
        let plot = AKNodeOutputPlot(SoundAnalyzer.shared.mic, frame: plotView.bounds)
        plot.autoresizingMask = .flexibleWidth
        plot.plotType = .buffer
        plot.shouldFill = true
        plot.gain = 1.4 // This number is multiplied by amplitude.
        plot.color = UIColor.soundIndicator
        plot.backgroundColor = UIColor.clear
        plotView.addSubview(plot)
        self.plot = plot
    }
    
    private func brand() {
        adjustmentLabel.textColor = UIColor.secondaryText
        calibrateButton.tintColor = UIColor.accent
    }
    
    // MARK: - Public Methods
    func pausePlot() {
        plot?.pause()
    }
    
    func resumePlot() {
        plot?.resume()
    }
    
    func update(adjustment: Double) {
        if adjustment >= 0.0 {
            adjustmentLabel.text = "(+\(String(format: "%0.1f", adjustment))\(Settings.shared.tensionUnit.rawValue))"
        } else {
            adjustmentLabel.text = "(\(String(format: "%0.1f", adjustment))\(Settings.shared.tensionUnit.rawValue))"
        }
    }
    
    func update(sample: SoundAnalyzerSample) {
        calibrateButton.isEnabled = true
        // Fabric value.
        fabricValueLabel.text = String(format: "%0.1f", sample.tensionNumber)
        // Personal (adjusted) value.
        personalValueLabel.text = String(format: "%0.1f", sample.tensionNumber + Settings.shared.tensionAdjustment)
    }
    
    @IBAction func adjustPressed(button: UIButton) {
        delegate?.adjustCellSelectAdjust(self)
    }

}
