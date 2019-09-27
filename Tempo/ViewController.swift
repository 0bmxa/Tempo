//
//  ViewController.swift
//  Tempo
//
//  Created by mxa on 18.09.2017.
//  Copyright © 2017 mxa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private weak var bpmLabel: UILabel!
    @IBOutlet private weak var infoLabel: UILabel!
    @IBOutlet private weak var beatIndicator: UILabel!
    @IBOutlet private weak var recordButton: UIButton!
    
//    private let infoText = "Tap the screen to the beat.\nTap with two fingers to reset."

    
    // Manual detection
    private let manualDetector = ManualTempoDetector()
    private let tapRecognizer = UITapGestureRecognizer()
    private let doubleTapRecognizer = UITapGestureRecognizer()

    // Audio detection
    private let audioDetector = MicrophoneTempoDetector()
    private var audioDetectionRunning: Bool = false {
        didSet {
            self.recordButton.isSelected = self.audioDetectionRunning
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTempoText(beatsPerMinute: 0)
        
        self.infoLabel.text = "Tap the screen to the beat.\nTap with two fingers to reset."
        self.infoLabel.alpha = 0.0
        self.showInfoLabel(after: 3.0)
        
        self.beatIndicator.alpha = 0.0
        
        self.manualDetector.tempoUpdateCallback = self.setTempoText
        self.manualDetector.beatOccurenceCallback = self.blinkBeatIndicator
        self.audioDetector.tempoUpdateCallback = { (bpm) in
            let alpha = CGFloat(bpm.confidence) * 0.5 + 0.5
            self.setTempoText(beatsPerMinute: bpm.bpm, alpha: alpha)
        }
        self.audioDetector.beatOccurenceCallback = self.blinkBeatIndicator

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
        guard !self.audioDetectionRunning else { return }
        self.manualDetector.addBeat()
        self.hideInfoLabel()
    }
    
    @objc func viewDoubleTapped() {
        guard !self.audioDetectionRunning else { return }
        self.manualDetector.reset()
        self.hideInfoLabel()
     }

    @IBAction func recordButtonClicked(_ recordButton: UIButton) {
        guard !self.audioDetectionRunning else {
            print("Stopping audio detection...")
            self.audioDetector.stop()
            self.audioDetectionRunning = false
            return
        }
        
        print("Checking microphone permission...")
        
        // Check mic permissions before starting
        self.audioDetector.checkPermissions { hasMicPermission in
            print("Has microphone permission:", hasMicPermission)
            guard hasMicPermission else {
                self.showMicPermissionError()
                self.audioDetectionRunning = false
                return
            }

            print("Starting audio detection...")

            // Try to start and update state (& button)
            let success = self.audioDetector.start()
            self.audioDetectionRunning = success
        }
    }
}


// MARK: - UI Update stuff
private extension ViewController {
    func setTempoText(beatsPerMinute: Float?) {
        self.setTempoText(beatsPerMinute: beatsPerMinute, alpha: 1.0)
    }
    
    func setTempoText(beatsPerMinute: Float?, alpha: CGFloat) {
        let bpm = beatsPerMinute ?? 0
//        let precision = 5.0
//        let rounded = (bpm/precision).rounded() * precision
        self.bpmLabel.text = String(format: "%.0f", bpm)
        self.bpmLabel.alpha = alpha
    }
    
    func showInfoLabel(after delay: Double) {
        UIView.animate(withDuration: 0.5, delay: delay, options: .beginFromCurrentState, animations: {
            self.infoLabel.alpha = 1.0
        }, completion: nil)
    }
    
    func hideInfoLabel() {
        UIView.animate(withDuration: 0.5, delay: 0.0, options: .beginFromCurrentState, animations: {
            self.infoLabel.alpha = 0.0
        }, completion: { [weak self]_ in
            self?.showInfoLabel(after: 7.0)
        })
    }

    func blinkBeatIndicator() {
        self.beatIndicator.alpha = 1.0
        UIView.animate(withDuration: 0.3, delay: 0, options: [], animations: {
            self.beatIndicator.alpha = 0.0
        }, completion: nil)
    }
    
    func showMicPermissionError() {
        let alert = UIAlertController(title: "Error", message: "Microphone access denied.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(UIAlertAction(title: "Go To Settings", style: .default) { _ in
            alert.dismiss(animated: false, completion: nil)
            let url = URL(string: UIApplicationOpenSettingsURLString)!
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        })
        self.present(alert, animated: true, completion: nil)
    }
}
