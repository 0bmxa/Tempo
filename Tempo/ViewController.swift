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
    
    private var taps: [TimeInterval] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.bpmLabel.text = "0"

        self.tapRecognizer.numberOfTapsRequired = 1
        self.tapRecognizer.numberOfTouchesRequired = 1
        self.doubleTapRecognizer.numberOfTapsRequired    = 1
        self.doubleTapRecognizer.numberOfTouchesRequired = 2
        
        self.view.addGestureRecognizer(self.tapRecognizer)
        self.view.addGestureRecognizer(self.doubleTapRecognizer)
        
        self.tapRecognizer.addTarget(self, action: #selector(self.viewTapped))
        self.doubleTapRecognizer.addTarget(self, action: #selector(self.viewDoubleTapped))
    }
    
    @objc func viewTapped() {
        let now = Date().timeIntervalSinceReferenceDate
        self.taps.append(now)
        
        guard
            self.taps.count > 2,
            let start = self.taps.first,
            let end = self.taps.last
        else { return }
        
        let duration = end - start
        let beats = self.taps.count - 1 // last tap just sets the end of the last beat
        let timePerBeat = duration / Double(beats)
        let beatsPerMinute = 60.0 / timePerBeat
        
        self.bpmLabel.text = String(format: "%.1f", beatsPerMinute)
    }
    
    @objc func viewDoubleTapped() {
        self.taps.removeAll()
        self.bpmLabel.text = "0"
    }
}

