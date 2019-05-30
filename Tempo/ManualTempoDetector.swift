//
//  ManualTempoDetector.swift
//  Tempo
//
//  Created by mxa on 30.05.2019.
//  Copyright © 2019 mxa. All rights reserved.
//

import Foundation

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
