//
//  Aubio.swift
//  Tempo
//
//  Created by mxa on 11.09.2019.
//  Copyright © 2019 mxa. All rights reserved.
//

import aubio
import Foundation

extension Aubio {
    class Tempo {
        private let detector: OpaquePointer
        private let scratchBuffer: Vector
        private let tempoData: Vector
        private let hopSize: UInt32
        
        private let silenceThreshold: Float = -90; // dB
        
        /// Creates a new tempo detection object.
        /// - Parameter bufferSize: Length of FFT
        /// - Parameter sampleRate: Sampling rate of the signal to analyze
        init(bufferSize: UInt32, sampleRate: UInt32) {
            self.hopSize = bufferSize / 4
            let detector = new_aubio_tempo("default", bufferSize, self.hopSize, sampleRate)
            assert(detector != nil)
            self.detector = detector!
            
            self.scratchBuffer = Vector(length: self.hopSize)
            self.tempoData = Vector(length: 2)
        }
        
        deinit {
            del_aubio_tempo(self.detector)
        }
        
        /// Execute a cycle of tempo detection
        /// - Parameter buffer: Audio buffer to analyze
        /// - Parameter size: The length (in samples) of the audio buffer
        /// - Parameter updateCallback: A callback to update with new data
        func detect(buffer: UnsafeMutablePointer<Float>, size: Int, updateCallback: @escaping (BPM, Bool) -> Void) {
            
            var offset = 0
            repeat {
                // Fill the input buffer
                let len = min(Int(self.hopSize), size - offset)
                self.scratchBuffer.fill(from: buffer + offset, length: len)

                // Do the deteciton
                aubio_tempo_do(self.detector, self.scratchBuffer._vector, self.tempoData._vector)

                offset += Int(self.hopSize)
            } while (offset < size)
            
            if(self.tempoData[0] != 0) {
                let t = self.detector
//                NSLog("beat at %.3fms, %.3fs, frame %d, %.2f bpm with confidence %.2f, was tatum %d\n",
//                    aubio_tempo_get_last_ms(t), aubio_tempo_get_last_s(t),
//                    aubio_tempo_get_last(t), aubio_tempo_get_bpm(t),
//                    aubio_tempo_get_confidence(t), aubio_tempo_was_tatum(t));
            }
            
            
            let bpm = self.getCurrentBPM()
            let isBeat = self.tempoData.getSample(position: 0) != 0
            updateCallback(bpm, isBeat)

//            // If a callback is preset, detect beat & silence, and call it
//            guard let updateCallback = updateCallback else { return }
//            let isBeat = self.tempoData.getSample(position: 0) != 0
//            updateCallback()
//            let isSilence = aubio_silence_detection(self.buffer.pointer, silenceThreshold) != 0
//            if isBeat && !isSilence {
//            if beatValue != 0 && silenceValue == 0 {
//                beatCallback()
//            }
        }
        
        func getCurrentBPM() -> Aubio.BPM {
            let bpm = aubio_tempo_get_bpm(self.detector)
            let confidence = aubio_tempo_get_confidence(self.detector)
            return BPM(bpm: bpm, confidence: confidence)
        }
    }
}


extension Aubio {
    struct BPM {
        let bpm: Float
        let confidence: Float
    }
}
