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
    
    init(timeIntervalToConsider: TimeInterval = 4.0) {
        self.timeIntervalToConsider = timeIntervalToConsider
    }

    internal func addBeat() {
        let now = Date().timeIntervalSinceReferenceDate
        self.beats.append(now)
        
        // Filter beats by time
        let relevantBeats = self.beats.filter { (now - $0) <= self.timeIntervalToConsider }
        
        guard relevantBeats.count >= 2 else {
            // In case there are no relevant beats -> reset
            if self.beats.count >= 2 {
                self.reset()
            }
            return
        }

        // Calculate avg time interval between beats
        let totalDuration = relevantBeats.last! - relevantBeats.first!
        let intervalCount = relevantBeats.count - 1
        let timePerBeat = totalDuration / TimeInterval(intervalCount)
        
        // To bpm
        let beatsPerMinute = 60.0 / timePerBeat
        self.tempoUpdateCallback?(beatsPerMinute)
    }
    
    internal func reset() {
        self.beats.removeAll()
        self.tempoUpdateCallback?(nil)
    }
}
