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
    
    @IBAction func act_changeMode(_ sender: AnyObject) {
        switch seg_mode.selectedSegmentIndex {
        case 0:
            print("hours", terminator: "")
            picker.changeMode(LETimeIntervalPicker.LETMode.hoursMinutesSeconds)
            label.text = "Changing Mode"
            break
        case 1:
            print("minutes", terminator: "")
            picker.changeMode(LETimeIntervalPicker.LETMode.minutesSeconds)
            label.text = "Changing Mode"
            break
        
        default:
            print("nothing selected", terminator: "")
        }
    }
    
    
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var picker: LETimeIntervalPicker!
    @IBOutlet weak var animated: UISwitch!
    
    @IBOutlet weak var seg_mode: UISegmentedControl!
    let formatter = DateComponentsFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        formatter.unitsStyle = .abbreviated
    }
    
    @IBAction func updateLabel(_ sender: LETimeIntervalPicker) {
        label.text = formatter.string(from: sender.timeInterval)
    }
    
    @IBAction func setRandomTimeInterval() {
        let random = TimeInterval(arc4random_uniform(60*60*24)) // Random time under 24 hours
        if animated.isOn {
            picker.setTimeIntervalAnimated(random)
        } else {
            picker.timeInterval = random
        }
    }
}
