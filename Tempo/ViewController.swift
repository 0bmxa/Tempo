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
    let tapRecognizer = UITapGestureRecognizer()
    let doubleTapRecognizer = UITapGestureRecognizer()
    
    private let tempoDetector = ManualTempoDetector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTempoText(beatsPerMinute: 0)
        
        self.infoLabel.text = "Tap the screen to the beat.\nTap with two fingers to reset."
        self.infoLabel.alpha = 0.0
        self.showInfoLabel(after: 3.0)
        
        self.tempoDetector.tempoUpdateCallback = self.setTempoText

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
        self.tempoDetector.addBeat()
        self.hideInfoLabel()
    }
    
    @objc func viewDoubleTapped() {
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
