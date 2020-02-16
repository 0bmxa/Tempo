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
    
    private var beats: [TimeInterval] = []
    private let timeIntervalToConsider: TimeInterval
    private var lastBPM: Double?
    
    private let smoothingFactor = 0.9 // 0 = no smoothing; 1 = no update
    private let significantChange = 10.0 // bpm

    init(timeIntervalToConsider: TimeInterval = 3.0) {
        self.timeIntervalToConsider = timeIntervalToConsider
    }

    internal func addBeat() {
        let now = Date().timeIntervalSinceReferenceDate
        self.beats.append(now)
        
        // Filter beats by time
        self.beats = self.beats.filter {
            (now - $0) <= self.timeIntervalToConsider
        }
        
        // Require at least 2 beats in the time interval
        guard beats.count >= 2 else {
            self.lastBPM = nil
            self.tempoUpdateCallback?(nil)
            return
        }

        // Calculate avg time interval between beats
        let totalDuration = self.beats.last! - self.beats.first!
        let intervalCount = self.beats.count - 1
        let timePerBeat = totalDuration / TimeInterval(intervalCount)

        // To bpm, smoothed
        let beatsPerMinute = self.smooth(bpm: 60.0 / timePerBeat)

        self.tempoUpdateCallback?(beatsPerMinute)
        self.lastBPM = beatsPerMinute
    }
    
    private func smooth(bpm: Double) -> Double {
        guard let lastBPM = self.lastBPM else { return bpm }

        // Don't smooth if change from last BPM is significant
        guard abs(bpm - lastBPM) <= self.significantChange else {
            self.lastBPM = nil
            return bpm
        }

        // Cheap low pass smoothing
        return smoothingFactor * lastBPM + (1 - smoothingFactor) * bpm
    }
    
    internal func reset() {
        self.beats.removeAll()
        self.lastBPM = nil
        self.tempoUpdateCallback?(nil)
    }
}
