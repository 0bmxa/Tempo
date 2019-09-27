//
//  MicrophoneTempoDetector.swift
//  Tempo
//
//  Created by mxa on 10.09.2019.
//  Copyright © 2019 mxa. All rights reserved.
//

import AVFoundation
import Foundation

class MicrophoneTempoDetector: TempoDetectorType {
    typealias TempoUpdateCallback = (Aubio.BPM) -> Void
    
    var tempoUpdateCallback: TempoUpdateCallback?
    var beatOccurenceCallback: BeatOccurenceCallback?
    
    private let session = AVAudioSession.sharedInstance()
    private let engine = AVAudioEngine()
    
    // Aubio stuff
    internal let aubioTempo: Aubio.Tempo
    private let buffer: Aubio.Vector
    
    // "Audio Settings"
    private let inputBus: AVAudioNodeBus = 0
    private let bufferSize: AVAudioFrameCount = 2048
    
    private var tapInstalled: Bool = false
    
    init() {
        // Create tempo detector
        let format = self.engine.inputNode.inputFormat(forBus: self.inputBus)
        guard format.sampleRate != 0 else { fatalError() }
        
        self.aubioTempo = Aubio.Tempo(bufferSize: bufferSize, sampleRate: UInt32(format.sampleRate))
        self.buffer = Aubio.Vector(length: bufferSize)
    }
    
    internal func checkPermissions(callback: @escaping (Bool) -> Void) {
        self.session.requestRecordPermission(callback)
    }
    
    internal func start() -> Bool {
        self.installTap()
        do {
            try self.engine.start()
        } catch {
            print(error)
            assertionFailure()
            return false
        }
        return true
    }
    
    internal func stop() {
        self.engine.stop()
        self.engine.inputNode.removeTap(onBus: self.inputBus)
    }
}


private extension MicrophoneTempoDetector {
    func installTap() {
        guard !self.tapInstalled else { return }
        let inputNode = self.engine.inputNode
        let format = inputNode.inputFormat(forBus: self.inputBus)
        guard format.sampleRate != 0 else { fatalError() }

        // Setup Tap on input node
        inputNode.installTap(onBus: inputBus, bufferSize: bufferSize, format: format, block: self.inputCallback)
        self.tapInstalled = true
    }
    
    
    /// The callback for the input node tap.
    ///
    /// - Parameter buffer: A buffer of audio captured from the output of an AVAudioNode
    /// - Parameter when: The time at which the buffer was captured
    func inputCallback(buffer: AVAudioPCMBuffer, when: AVAudioTime) {
        guard buffer.stride == 1 else { fatalError("ERROR: Format is interleaved") }
        guard let floatBuffer = buffer.floatChannelData?[0] else { fatalError("ERROR: Format is not float") }
        
        let sampleCount = Int(buffer.frameLength)        
        self.aubioTempo.detect(buffer: floatBuffer, size: sampleCount, updateCallback: self.updateUI)
    }
    
    private func updateUI(bpm: Aubio.BPM, isBeat: Bool) {
        DispatchQueue.main.async {

//            print("BPM:", bpm, "is beat:", isBeat)
            self.tempoUpdateCallback?(bpm)
            if isBeat {
                self.beatOccurenceCallback?()
            }

        }
    }
}
