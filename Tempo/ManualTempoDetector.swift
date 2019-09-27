//
//  ManualTempoDetector.swift
//  Tempo
//
//  Created by mxa on 30.05.2019.
//  Copyright © 2019 mxa. All rights reserved.
//

import Foundation

protocol TempoDetectorType {
    associatedtype TempoUpdateCallback
    typealias BeatOccurenceCallback = () -> Void
    var tempoUpdateCallback: TempoUpdateCallback? { get set }
    var beatOccurenceCallback: BeatOccurenceCallback? { get set }
}

class ManualTempoDetector: TempoDetectorType {
    typealias TempoUpdateCallback = (Float?) -> Void
    internal var tempoUpdateCallback: TempoUpdateCallback?
    internal var beatOccurenceCallback: BeatOccurenceCallback?
    
    private var beats: [TimeInterval] = []
    private let timeIntervalToConsider: TimeInterval
    
    init(timeIntervalToConsider: TimeInterval = 3.0) {
        self.timeIntervalToConsider = timeIntervalToConsider
    }

    internal func addBeat() {
        let now = Date().timeIntervalSinceReferenceDate
        self.beats.append(now)
        
        // Filter beats by time
        let relevantBeats = self.beats.filter { (now - $0) <= self.timeIntervalToConsider }
        
        guard relevantBeats.count >= 2 else {
            // In case there are no relevant beats, but other beats -> reset
            if self.beats.count >= 2 {
                self.reset()
            }
            return
        }

        // Calculate avg time interval between beats
        let totalDuration = relevantBeats.last! - relevantBeats.first!
        let intervalCount = relevantBeats.count - 1
        let timePerBeat = totalDuration / TimeInterval(intervalCount)
        
//        // Median
//        var intervals: [TimeInterval] = []
//        for i in 0..<relevantBeats.count-1 {
//            intervals.append(relevantBeats[i+1] - relevantBeats[i])
//        }
//        intervals.sort()
//        let medianIntervalIndex = intervals.count / 2
//        let timePerBeat = intervals[medianIntervalIndex]
        
        
        // To bpm
        let beatsPerMinute = 60.0 / Float(timePerBeat)
        self.tempoUpdateCallback?(beatsPerMinute)
    }
    
    internal func reset() {
        self.beats.removeAll()
        self.tempoUpdateCallback?(nil)
    }
}
