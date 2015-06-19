//
//  ViewController.swift
//  LETimeIntervalPickerExample
//
//  Created by Ludvig Eriksson on 2015-06-04.
//  Copyright (c) 2015 Ludvig Eriksson. All rights reserved.
//

import UIKit
import LETimeIntervalPicker

class ViewController: UIViewController {
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var picker: LETimeIntervalPicker!
    @IBOutlet weak var animated: UISwitch!
    
    let formatter = NSDateComponentsFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.unitsStyle = .Abbreviated
    }
    
    @IBAction func updateLabel(sender: LETimeIntervalPicker) {
        label.text = formatter.stringFromTimeInterval(sender.timeInterval)

    }
    
    @IBAction func setRandomTimeInterval() {
        let random = NSTimeInterval(arc4random_uniform(60*60*24)) // Random time under 24 hours
        if animated.on {
            picker.setTimeIntervalAnimated(random)

        } else {
            picker.timeInterval = random
        }
    }
}