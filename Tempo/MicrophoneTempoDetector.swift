//
//  MicrophoneTempoDetector.swift
//  Tempo
//
//  Created by mxa on 10.09.2019.
//  Copyright © 2019 mxa. All rights reserved.
//

import AVFoundation

class MicrophoneTempoDetector: TempoDetectorType {
    var tempoUpdateCallback: TempoUpdateCallback?
    
    let session = AVAudioSession.sharedInstance()
    let engine = AVAudioEngine()
    
    // Aubio stuff
    let aubioDetector: Aubio.Tempo
    let buffer: Aubio.Vector
    
    init() {
        let inputNode = self.engine.inputNode
        let inputBus: AVAudioNodeBus = 0
        let bufferSize: AVAudioFrameCount = 2048
        let format = inputNode.inputFormat(forBus: inputBus)
        
        guard format.sampleRate != 0 else { fatalError() }
        
        // Create tempo detector
        self.aubioDetector = Aubio.Tempo(bufferSize: bufferSize, sampleRate: UInt32(format.sampleRate))
        self.buffer = Aubio.Vector(length: bufferSize)

        // Setup Tap on input node
        inputNode.installTap(onBus: inputBus, bufferSize: bufferSize, format: format, block: self.inputCallback)
        
        start()
    }
    
    func start() {
        try! self.engine.start()
    }
    
    /// The callback for the input node tap.
    ///
    /// - Parameter buffer: A buffer of audio captured from the output of an AVAudioNode
    /// - Parameter when: The time at which the buffer was captured
    private func inputCallback(buffer: AVAudioPCMBuffer, when: AVAudioTime) {
        guard buffer.stride == 1 else { fatalError("ERROR: Format is interleaved") }
        guard let floatBuffer = buffer.floatChannelData?[0] else { fatalError("ERROR: Format is not floar") }
        
//        let sampleCount = buffer.frameLength
//        
//        let bufferPointer = UnsafeBufferPointer(start: floatBuffer, count: Int(buffer.frameLength))
//        let count = Int(bufferPointer.max()! * 10)
//        print(String(repeating: " ", count: count), "|")
        
        self.aubioDetector.detect(buffer: floatBuffer) {
            print("Now")
        }
        
    }
    
}
