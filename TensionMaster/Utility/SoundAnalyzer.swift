//
//  SoundAnalyzer.swift
//  TensionMaster
//
//  Created by Nikolay Markov on 10/28/18.
//  Copyright © 2018 Nikolay Markov. All rights reserved.
//

import Foundation
import AudioKit

struct SoundAnalyzerSample {
    let amplitude: Double
    let frequency: Double
    var isValid: Bool {
        return amplitude > 0.05 && frequency > 370 && frequency < 700
    }
    var tensionNumber: Double {
        let settings = Settings.shared
        let d1 = settings.stringDiameter
        let c1 = settings.stringType.coefficient
        let openingSize = settings.openingSize.coefficient
        let style = settings.stringerStyle.coefficient
        let patt = settings.stringPattern.coefficient
        var p = d1 * d1 * c1
        if settings.hybridStringing {
            let d2 = settings.crossStringDiameter
            let c2 = settings.crossStringType.coefficient
            p = (p + d2 * d2 * c2) / 2
        }
        var s = settings.headSize   // It should be in inches!
        if settings.headSizeUnit == .cm {
            s = s / 6.4516
        }
        
        let tensionInKg = 3.5e-7 * p * s * frequency * frequency * openingSize * style * patt
        if settings.tensionUnit == .kg {
            return tensionInKg
        } else {
            return tensionInKg * 2.20462262
        }
    }
}

protocol SoundAnalyzerDelegate: class {
    func soundAnalyzerSample(_ sample: SoundAnalyzerSample)
}

class SoundAnalyzer {
    
    static let shared = SoundAnalyzer()
    var delegate: SoundAnalyzerDelegate? {
        didSet {
            // Update the idle timer in depends of whether there is someone interested of the envets.
            UIApplication.shared.isIdleTimerDisabled = (delegate != nil)
        }
    }
    var isAnalyzing = false
    private var timerQueue = DispatchQueue(label: "Timer", qos: .background, attributes: .concurrent)
    private var updateTimer: Timer?
    
    private var frequencyTable = Array<Double>()
    
    // AudioKit releated.
    var mic: AKMicrophone
    lazy var tracker = AKFrequencyTracker(mic)
    lazy var booster = AKBooster(tracker, gain: 0)
    
    init() {
        // Set the AK sample rate to hardware supported sample rate
        let inputAudioFormat = AKManager.engine.inputNode.inputFormat(forBus: 0)
        let sampleRate = inputAudioFormat.sampleRate
        AKSettings.sampleRate = sampleRate
        if let mic = AKMicrophone(with: inputAudioFormat) {
            self.mic = mic
        } else {
            fatalError("AKMicrophone cannot be created with format: \(inputAudioFormat)")
        }
    }
    
    func start(completion: @escaping (Bool) -> Void) {
        if isAnalyzing {
            completion(true)    // Already started.
        }
        let startAnalyzingBlock: () -> Void = {
            // Start audio kit processing.
            AKSettings.audioInputEnabled = true
            AKManager.output = self.booster
            do {
                try AKManager.start()
                print("AudioKit started.")
            } catch {
                print("AudioKit did not start!")
                completion(false)
                return
            }
            // Trigger update functionality in dedicated timer queue.
            // Interval = 0.1 ==> 10 ticks (updates) per second.
            self.timerQueue.async {
                let currentRunLoop = RunLoop.current
                self.updateTimer = Timer(timeInterval: 0.1, repeats: true) { _ in
                    let sample = SoundAnalyzerSample(amplitude: self.tracker.amplitude,
                                                     frequency: self.tracker.frequency)
                    if sample.isValid {
                        // Check against the frequency table. It contains values +- 2 around every found frequency.
                        let frequencyRange = sample.frequency-2...sample.frequency+2
//                        print("---> frequency - \(sample.frequency)")
                        let match = self.frequencyTable.contains { previous -> Bool in
                            if frequencyRange.contains(previous) {
                                return true
                            }
                            return false
                        }
                        if match {
//                            print("-------> match found!")
                            self.frequencyTable.removeAll()
                            self.delegate?.soundAnalyzerSample(sample)
                        } else {
//                            print("-------> values: ", separator: "")
//                            for value in self.frequencyTable {
//                                print("\(value)", separator: "")
//                            }
//                            print("")
                            self.frequencyTable.append(sample.frequency)
                            // Keep the table with no more than 3 records.
                            if self.frequencyTable.count > 3 {
                                self.frequencyTable.removeFirst()
                            }
                        }
                    }
                }
                currentRunLoop.add(self.updateTimer!, forMode: .common)
                currentRunLoop.run()
            }
            
            // Notify.
            self.isAnalyzing = true
            completion(true)
        }
        switch AVAudioSession.sharedInstance().recordPermission {
        case .granted:
            startAnalyzingBlock()   // Granted.
        case .denied:
            completion(false)   // Denied.
        case .undetermined:
            AVAudioSession.sharedInstance().requestRecordPermission { granted in
                if granted {
                    startAnalyzingBlock()   // Granted.
                } else {
                    completion(false)   // Denied.
                }
            }
        }
    }
    
    func stop() {
        if isAnalyzing == false {
            return
        }
        do {
            try AKManager.stop()
            print("AudioKit stopped.")
        } catch {
            print("Cannot stop the audio kit...")   // Check how to handle it better...
        }
        timerQueue.sync {
            self.updateTimer?.invalidate()
            self.updateTimer = nil
        }
        self.isAnalyzing = false
    }
    
}
