//
//  TableViewController.swift
//  LETimeIntervalPicker
//
//  Created by Ludvig Eriksson on 2015-06-05.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import LETimeIntervalPicker

class TableViewController: UITableViewController {
    
    // MARK: - Outlets & properties
    
    @IBOutlet weak var detailLabel: UILabel!
    
    @IBOutlet weak var picker: LETimeIntervalPicker!
    var pickerIsVisible = false
    let formatter = DateComponentsFormatter()
    
    // MARK: - View controller lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        formatter.unitsStyle = .abbreviated
        detailLabel.text = formatter.string(from: 0)
        picker.maxTimeInterval = 43200; // 12h
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        tableView.beginUpdates()
        pickerIsVisible = !pickerIsVisible
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1 {
            if pickerIsVisible {
                return 216
            } else {
                return 0
            }
        }
        return tableView.rowHeight
    }
    
    // MARK: - Actions
    
    @IBAction func pickerChanged(_ sender: LETimeIntervalPicker) {
        detailLabel.text = formatter.string(from: sender.timeInterval)
    }
    
}
