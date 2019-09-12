//
//  Aubio.swift
//  Tempo
//
//  Created by mxa on 11.09.2019.
//  Copyright © 2019 mxa. All rights reserved.
//

import aubio

typealias Closure = () -> Void

struct Aubio {
    class Tempo {
        private let detector: OpaquePointer!
        private let buffer: Vector
        private let tempoData: Vector
        
        private let silenceThreshold: Float = -90; // dB
        
        /// Creates a new tempo detection object.
        /// - Parameter bufferSize: Length of FFT
        /// - Parameter sampleRate: Sampling rate of the signal to analyze
        init(bufferSize: UInt32, sampleRate: UInt32) {
            let method = "default".withCString { $0 }
            let hopSize = bufferSize / 4
            self.detector = new_aubio_tempo(method, bufferSize, hopSize, sampleRate)
            
            self.buffer = Vector(length: bufferSize)
            self.tempoData = Vector(length: 2)
        }
        
        deinit {
            del_aubio_tempo(self.detector)
        }
        
        /// Execute tempo detection
        /// - Parameter in: Input new samples
        func detect(buffer: UnsafeMutablePointer<Float>, beatCallback: Closure?) {
            // Store the input buffer pointer
            self.buffer.pointer.pointee.data = buffer
            
            // Do the deteciton
            aubio_tempo_do(self.detector, self.buffer.pointer, self.tempoData.pointer)
            
            // If a beat callback is preset, detect beat & silence, and call it
            guard let beatCallback = beatCallback else { return }
            let beatValue = self.tempoData.getSample(position: 0)
            let silenceValue = aubio_silence_detection(self.buffer.pointer, silenceThreshold)
            if beatValue != 0 && silenceValue == 0 {
                beatCallback()
            }
        }
        
        func getCurrentBPM() -> Float {
            return aubio_tempo_get_bpm(self.detector)
        }
    }
    
    class Vector {
        internal let pointer: UnsafeMutablePointer<fvec_t>!
        
        init(length: UInt32) {
            self.pointer = new_fvec(length)
        }
        
        deinit {
            del_fvec(self.pointer)
        }
        
        func getSample(position: UInt32) -> Float {
            return fvec_get_sample(self.pointer, position)
        }
    }
}
