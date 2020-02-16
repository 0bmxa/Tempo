//
//  ViewController.swift
//  Tempo
//
//  Created by mxa on 18.09.2017.
//  Copyright © 2017 mxa. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var bpmLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    private let tempoDetector = ManualTempoDetector()
    private var previousTouch: TimeInterval = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTempoText(beatsPerMinute: 0)
        
        self.infoLabel.text = "Tap the screen to the beat.\nTap with two fingers to reset."
        self.infoLabel.alpha = 0.0
        self.showInfoLabel(after: 3.0)
        
        self.tempoDetector.tempoUpdateCallback = self.setTempoText
        
        // Allow touch detection on main view
        self.view.isUserInteractionEnabled = true
        self.view.isMultipleTouchEnabled = true
        self.bpmLabel.isUserInteractionEnabled = false
        self.infoLabel.isUserInteractionEnabled = false
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let now = Date().timeIntervalSinceReferenceDate

        // Tap with 2+ fingers
        // Note: If the last two taps are less than 0.2 seconds apart,
        // we're either trying to detect 300+ bpm or we missed a two finger tap
        if touches.count >= 2 || now - previousTouch < 0.2 {
            self.twoFingersTapped()
            self.previousTouch = 0
            return
        }

        // Regular tempo tap (single finger on touch down)
        self.viewTapped()
        self.previousTouch = now
    }

    @objc func viewTapped() {
        self.tempoDetector.addBeat()
        self.hideInfoLabel()
    }
    
    @objc func twoFingersTapped() {
        self.tempoDetector.reset()
        self.hideInfoLabel()
     }

    func setTempoText(beatsPerMinute: Double?) {
        let bpm = beatsPerMinute ?? 0
        self.bpmLabel.text = String(format: "%.0f", bpm)
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
}
