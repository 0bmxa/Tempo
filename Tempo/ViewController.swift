//
//  ViewController.swift
//  Tempo
//
//  Created by mxa on 18.09.2017.
//  Copyright © 2017 mxa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var bpmLabel: UILabel!
    let tapRecognizer = UITapGestureRecognizer()
    let doubleTapRecognizer = UITapGestureRecognizer()
    
    private let tempoDetector = ManualTempoDetector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTempoText(beatsPerMinute: 0)
        
        self.tempoDetector.tempoUpdateCallback = self.setTempoText

        // Tempo (single tap) recognizer
        self.tapRecognizer.numberOfTapsRequired    = 1
        self.tapRecognizer.numberOfTouchesRequired = 1
        self.view.addGestureRecognizer(self.tapRecognizer)
        self.tapRecognizer.addTarget(self, action: #selector(self.viewTapped))

        // Reset (double tap) recognizer
        self.doubleTapRecognizer.numberOfTapsRequired    = 1
        self.doubleTapRecognizer.numberOfTouchesRequired = 2
        self.view.addGestureRecognizer(self.doubleTapRecognizer)
        self.doubleTapRecognizer.addTarget(self, action: #selector(self.viewDoubleTapped))
    }
    
    @objc func viewTapped() {
        self.tempoDetector.addBeat()
    }
    
    @objc func viewDoubleTapped() {
        self.tempoDetector.reset()
    }

    func setTempoText(beatsPerMinute: Double?) {
        let bpm = beatsPerMinute ?? 0
        self.bpmLabel.text = String(format: "%.0f", bpm)
    }
}



class ManualTempoDetector {
    typealias TempoUpdateCallback = (Double?) -> Void
    internal var tempoUpdateCallback: TempoUpdateCallback?

    private var lastBeat: TimeInterval?
    private var intervals: [TimeInterval] = []

    internal func addBeat() {
        let now = Date().timeIntervalSinceReferenceDate
        
        if let lastBeat = self.lastBeat {
            self.intervals.append(now - lastBeat)
        }
        self.lastBeat = now
        
        let timePerBeat: Double
        
        switch self.intervals.count {
        case 0:
            return
            
        case 1..<3:  // Average
            let sum = self.intervals.reduce(0) { $0 + $1 }
            timePerBeat = sum / Double(self.intervals.count)
            
        case 3..<10:  // "Smoothed" average (w/o min/max)
            let sum = self.intervals.reduce(0) { $0 + $1 }
            let min = self.intervals.min() ?? 0
            let max = self.intervals.max() ?? 0
            timePerBeat = (sum - min - max) / Double(self.intervals.count - 2)
            
        default:  // "Smoothed" average of last 10 (w/o min/max -> 8) elements
            let last10Intervals = self.intervals.dropFirst(self.intervals.count - 10)
            let sum = last10Intervals.reduce(0) { $0 + $1 }
            let min = last10Intervals.min() ?? 0
            let max = last10Intervals.max() ?? 0
            timePerBeat = (sum - min - max) / 8
        }
        
        let beatsPerMinute = 60.0 / timePerBeat
        self.tempoUpdateCallback?(beatsPerMinute)
    }
    
    internal func reset() {
        self.lastBeat = nil
        self.intervals.removeAll()
        self.tempoUpdateCallback?(nil)
    }
}
