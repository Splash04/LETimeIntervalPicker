//
//  LETimeIntervalPicker.swift
//  LETimeIntervalPickerExample
//
//  Created by Ludvig Eriksson on 2015-06-04.
//  Copyright (c) 2015 Ludvig Eriksson. All rights reserved.
//

import UIKit

open class LETimeIntervalPicker: UIControl, UIPickerViewDataSource, UIPickerViewDelegate {
    
    // MARK: - Public API
    
    open var timeInterval: TimeInterval {
        get {
            let hours = pickerView.selectedRow(inComponent: 0) * 60 * 60
            let minutes = pickerView.selectedRow(inComponent: 1) * 60
            let seconds = pickerView.selectedRow(inComponent: 2)
            return TimeInterval(hours + minutes + seconds)
        }
        set {
            setPickerToTimeInterval(newValue, animated: false)
        }
    }
    
    open var timeIntervalAsHoursMinutesSeconds: (hours: Int, minutes: Int, seconds: Int) {
        get {
            return secondsToHoursMinutesSeconds(Int(timeInterval))
        }
    }
    open var timeIntervalAsMinutesSeconds: (minutes: Int, seconds: Int) {
        get {
            return secondsToMinutesSeconds(Int(timeInterval))
        }
    }
    open func setTimeIntervalAnimated(_ interval: TimeInterval) {
        setPickerToTimeInterval(interval, animated: true)
    }
    
    open func resetTimetoZero(_ animated: Bool) {
        setPickerToTimeInterval(TimeInterval(0), animated: animated)
    }
    
    //Mark: Change Timer Mode Methods
    public enum LETMode:Int {
        case hoursMinutesSeconds = 3
        case minutesSeconds = 2
    }
    
    // Managing the current Mode for the Picker
    open var currentMode = LETMode.hoursMinutesSeconds // Default Mode
    
    fileprivate var componentsToShow:[Components] = [Components.hour,Components.minute, Components.second]
    open func changeMode(_ newMode : LETMode) {
        currentMode = newMode
        cleanup() // Hour label doesn't seem to be removed when calling setup so removing them manually here
        setup()
    }
    
    // Note that setting a font that makes the picker wider
    // than this view can cause layout problems
    open var font:UIFont = pickerStyle.styleSelectedFont! {
        didSet {
            refreshViewAfterFormatChange()
        }
    }
    
    open var fontColor:UIColor = pickerStyle.styleFontColor {
        didSet {
            refreshViewAfterFormatChange()
        }
    }
    
    // MARK: - UI Components
    
    fileprivate let pickerView = UIPickerView()
    
    fileprivate let hourLabel = UILabel()
    fileprivate let minuteLabel = UILabel()
    fileprivate let secondLabel = UILabel()
    
    // MARK: - Max Time
    open var maxTimeInterval : TimeInterval = 86400 {
        didSet {
            pickerView.reloadAllComponents()
        }
    }
    
    // MARK: - Initialization
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    fileprivate func refreshViewAfterFormatChange() {
        updateLabels()
        calculateNumberWidth()
        calculateTotalPickerWidth()
        pickerView.reloadAllComponents()
    }
    fileprivate func setup() {
        setupLocalizations()
        setupLabels()
        calculateNumberWidth()
        calculateTotalPickerWidth()
        setupPickerView()
    }
    fileprivate func cleanup() {
        hourLabel.removeFromSuperview()
        minuteLabel.removeFromSuperview()
        secondLabel.removeFromSuperview()
        resetTimetoZero(true)
    }
    fileprivate func setupLabels() {
        switch currentMode {
        case LETMode.hoursMinutesSeconds :
            hourLabel.text = hoursString
            hourLabel.textColor = fontColor
            if currentMode == LETMode.hoursMinutesSeconds {
                addSubview(hourLabel)
            }
            fallthrough
        case LETMode.minutesSeconds:
            minuteLabel.text = minutesString
            minuteLabel.textColor = fontColor
            addSubview(minuteLabel)
            secondLabel.text = secondsString
            secondLabel.textColor = fontColor
            addSubview(secondLabel)
            updateLabels()
        }
        
        
        
        
    }
    
    fileprivate func updateLabels() {
        
        hourLabel.font = font
        hourLabel.textColor = fontColor
        hourLabel.sizeToFit()
        minuteLabel.font = font
        minuteLabel.textColor = fontColor
        minuteLabel.sizeToFit()
        secondLabel.font = font
        secondLabel.textColor = fontColor
        secondLabel.sizeToFit()
    }
    
    fileprivate func calculateNumberWidth() {
        let label = UILabel()
        label.font = font
        numberWidth = 0
        for i in 0...59 {
            label.text = "\(i)"
            label.sizeToFit()
            if label.frame.width > numberWidth {
                numberWidth = label.frame.width
            }
        }
    }
    
    func calculateTotalPickerWidth() {
        // Used to position labels
        
        totalPickerWidth = 0
        totalPickerWidth += hourLabel.bounds.width
        totalPickerWidth += minuteLabel.bounds.width
        totalPickerWidth += secondLabel.bounds.width
        
        
        totalPickerWidth += standardComponentSpacing * 2
        totalPickerWidth += extraComponentSpacing * 3
        totalPickerWidth += labelSpacing * 3
        totalPickerWidth += numberWidth * 3
    }
    
    func setupPickerView() {
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(pickerView)
        
        // Size picker view to fit self
        let top = NSLayoutConstraint(item: pickerView,
            attribute: .top,
            relatedBy: .equal,
            toItem: self,
            attribute: .top,
            multiplier: 1,
            constant: 0)
        
        let bottom = NSLayoutConstraint(item: pickerView,
            attribute: .bottom,
            relatedBy: .equal,
            toItem: self,
            attribute: .bottom,
            multiplier: 1,
            constant: 0)
        
        let leading = NSLayoutConstraint(item: pickerView,
            attribute: .leading,
            relatedBy: .equal,
            toItem: self,
            attribute: .leading,
            multiplier: 1,
            constant: 0)
        
        let trailing = NSLayoutConstraint(item: pickerView,
            attribute: .trailing,
            relatedBy: .equal,
            toItem: self,
            attribute: .trailing,
            multiplier: 1,
            constant: 0)
        
        addConstraints([top, bottom, leading, trailing])
    }
    
    // MARK: Style
    public struct pickerStyle {
        static let styleFontSize:CGFloat = 20
        static let styleSelectedFont = UIFont(name: "Apple SD Gothic Neo", size: pickerStyle.styleFontSize) // SD Font
        static let styleFontColor = UIColor.blue
        
    }
    
    // MARK: - Layout
    fileprivate var totalPickerWidth: CGFloat = 0
    fileprivate var numberWidth: CGFloat = 20               // Width of UILabel displaying a two digit number with standard font
    
    fileprivate let standardComponentSpacing: CGFloat = 5   // A UIPickerView has a 5 point space between components
    fileprivate let extraComponentSpacing: CGFloat = 10     // Add an additional 10 points between the components
    fileprivate let labelSpacing: CGFloat = 5               // Spacing between picker numbers and labels
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        // Reposition labels
        if currentMode == LETMode.hoursMinutesSeconds {
            hourLabel.center.y = pickerView.frame.midY
        }
        minuteLabel.center.y = pickerView.frame.midY
        secondLabel.center.y = pickerView.frame.midY
        
        let pickerMinX = bounds.midX - totalPickerWidth / 2
        hourLabel.frame.origin.x = pickerMinX + numberWidth + labelSpacing
        let space = standardComponentSpacing + extraComponentSpacing + numberWidth + labelSpacing
        minuteLabel.frame.origin.x = hourLabel.frame.maxX + space
        secondLabel.frame.origin.x = minuteLabel.frame.maxX + space
    }
    
    // MARK: - Picker view data source
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        let currentComponent = componentsToShow[component]
        let minutes = (Int) (maxTimeInterval > 3600 ? 60 : maxTimeInterval / 60)
        let seconds = (Int) (maxTimeInterval > 60 ? 60 : maxTimeInterval)
        switch currentComponent {
        case .hour:
            return (Int) (maxTimeInterval / 3600)
        case .minute:
            return minutes
        case .second:
            return seconds
        }
    }
    
    // MARK: - Picker view delegate
    
    open func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        var labelWidth: CGFloat = 0
        switch Components(rawValue: component)! {
        case .hour:
            labelWidth = hourLabel.bounds.width
            
        case .minute:
            labelWidth = minuteLabel.bounds.width
        case .second:
            labelWidth = secondLabel.bounds.width
        }
        return numberWidth + labelWidth + labelSpacing + extraComponentSpacing
    }
    
    open func pickerView(_ pickerView: UIPickerView,
        viewForRow row: Int,
        forComponent component: Int,
        reusing view: UIView?) -> UIView {
            
            // Check if view can be reused
            var newView = view
            
            if newView == nil {
                // Create new view
                let size = pickerView.rowSize(forComponent: component)
                newView = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
                
                // Setup label and add as subview
                let label = UILabel()
                label.font = font
                label.textColor = fontColor
                label.textAlignment = .right
                label.adjustsFontSizeToFitWidth = false
                label.frame.size = CGSize(width: numberWidth, height: size.height)
                newView!.addSubview(label)
            }
            
            let label = newView!.subviews.first as! UILabel
            if currentMode == LETMode.minutesSeconds && component == 0 {
            }
            else {
                label.text = "\(row)"
            }
            
            return newView!
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if row == 1 {
            // Change label to singular
            switch Components(rawValue: component)! {
            case .hour:
                hourLabel.text = hourString
            case .minute:
                minuteLabel.text = minuteString
            case .second:
                secondLabel.text = secondString
            }
        } else {
            // Change label to plural
            switch Components(rawValue: component)! {
            case .hour:
                hourLabel.text = hoursString
            case .minute:
                minuteLabel.text = minutesString
            case .second:
                secondLabel.text = secondsString
            }
        }
        
        if currentMode == LETMode.minutesSeconds && component == 0 {
            //don't allow hour to be selected.
        }
        else {
            sendActions(for: .valueChanged)
        }
    }
    
    // MARK: - Helpers
    
    fileprivate func setPickerToTimeInterval(_ interval: TimeInterval, animated: Bool) {
        let time = secondsToHoursMinutesSeconds(Int(interval))
        if currentMode == LETMode.hoursMinutesSeconds {
            pickerView.selectRow(time.hours, inComponent: 0, animated: animated)
            self.pickerView(pickerView, didSelectRow: time.hours, inComponent: 0)
        }
        pickerView.selectRow(time.minutes, inComponent: 1, animated: animated)
        pickerView.selectRow(time.seconds, inComponent: 2, animated: animated)
        self.pickerView(pickerView, didSelectRow: time.minutes, inComponent: 1)
        self.pickerView(pickerView, didSelectRow: time.seconds, inComponent: 2)
    }
    
    fileprivate func secondsToHoursMinutesSeconds(_ seconds : Int) -> (hours: Int, minutes: Int, seconds: Int) {
        return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    fileprivate func secondsToMinutesSeconds(_ seconds : Int) -> (minutes: Int, seconds: Int) {
        return ((seconds % 3600) / 60, (seconds % 3600) % 60)
    }
    
    fileprivate enum Components: Int {
        case hour = 0
        case minute = 1
        case second = 2
    }
    
    // MARK: - Localization
    
    fileprivate var hoursString     = "hours"
    fileprivate var hourString      = "hour"
    fileprivate var minutesString   = "minutes"
    fileprivate var minuteString    = "minute"
    fileprivate var secondsString   = "seconds"
    fileprivate var secondString    = "second"
    
    fileprivate func setupLocalizations() {
        
        let bundle = Bundle(for: LETimeIntervalPicker.self)
        let tableName = "LETimeIntervalPicker.bundle/LETimeIntervalPickerLocalizable"
        
        hoursString = NSLocalizedString("hours", tableName: tableName, bundle: bundle,
            comment: "The text displayed next to the hours component of the picker.")
        
        hourString = NSLocalizedString("hour", tableName: tableName, bundle: bundle,
            comment: "A singular alternative for the hours text.")
        
        minutesString = NSLocalizedString("minutes", tableName: tableName, bundle: bundle,
            comment: "The text displayed next to the minutes component of the picker.")
        
        minuteString = NSLocalizedString("minute", tableName: tableName, bundle: bundle,
            comment: "A singular alternative for the minutes text.")
        
        secondsString = NSLocalizedString("seconds", tableName: tableName, bundle: bundle,
            comment: "The text displayed next to the seconds component of the picker.")
        
        secondString = NSLocalizedString("second", tableName: tableName, bundle: bundle,
            comment: "A singular alternative for the seconds text.")
    }
}
