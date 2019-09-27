//
//  TempoTests.swift
//  TempoTests
//
//  Created by mxa on 16.09.2019.
//  Copyright © 2019 mxa. All rights reserved.
//

import XCTest
@testable import Tempo
import AVFoundation

class TempoTests: XCTestCase {

    private var testFileBuffer: AVAudioPCMBuffer = {
        let testsBundle = Bundle(for: TempoTests.self)
        let url = testsBundle.url(forResource: "test_beat", withExtension: "wav")!
        let file = try! AVAudioFile(forReading: url)

        let buffer = file.bufferRepresentation
        assert(buffer.floatChannelData != nil)
        assert(!buffer.format.isInterleaved)
        return buffer
    }()

//    func testAubioTempoDetection() {
//        let bufferSize: UInt32 = 1024
//        let tempo = Aubio.Tempo(bufferSize: bufferSize, sampleRate: 44100)
//
//        let testBuffer = testFileBuffer.floatChannelData![0]
//
//        let rounds = (testFileBuffer.frameCapacity / bufferSize)
//        for i in 0..<rounds {
//            let offset = Int(i * bufferSize)
//            let readPos = testBuffer.advanced(by: offset)
//            tempo.detect(buffer: readPos, updateCallback: {_,_ in })
//        }
//
//        let bpm = tempo.getCurrentBPM()
//        XCTAssertEqual(bpm.bpm, 120, accuracy: 2.0)
//        XCTAssertEqual(bpm.confidence, 1.0, accuracy: 0.2)
//    }
  
    func testAubioTempoConfidence() {
        let bufferSizes: [UInt32] = [128, 256, 512, 1024, 2048, 4096, 8192, 16384]
        for bufferSize in bufferSizes {
            self.foo(bufferSize: bufferSize)
        }
    }

    func foo(bufferSize: UInt32) {
        let tempo = Aubio.Tempo(bufferSize: bufferSize, sampleRate: 44100)

        var offset = 0
        repeat {
            let len = Int(min(bufferSize, testFileBuffer.frameCapacity - UInt32(offset)))
            tempo.detect(buffer: testFileBuffer.floatChannelData![0] + offset, size: len, updateCallback: {_,_ in })
            
            offset += Int(bufferSize)
        } while (offset < testFileBuffer.frameCapacity)

        let bpm = tempo.getCurrentBPM()
        print("bufferSize:", bufferSize, "-> bpm:", bpm.bpm, ", confidence:", bpm.confidence)
    }
}

extension AVAudioFile {
    var bufferRepresentation: AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(self.length)
        let buffer = AVAudioPCMBuffer(pcmFormat: self.processingFormat, frameCapacity: frameCount)!
        try! self.read(into: buffer)
        return buffer
    }
}
