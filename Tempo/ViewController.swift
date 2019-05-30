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
    let tapRecognizer = UITapGestureRecognizer()
    let doubleTapRecognizer = UITapGestureRecognizer()
    
    private let tempoDetector = ManualTempoDetector()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setTempoText(beatsPerMinute: 0)
        
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
    }
    
    @objc func viewDoubleTapped() {
        self.tempoDetector.reset()
    }

    func setTempoText(beatsPerMinute: Double?) {
        let bpm = beatsPerMinute ?? 0
        self.bpmLabel.text = String(format: "%.0f", bpm)
    }
}
