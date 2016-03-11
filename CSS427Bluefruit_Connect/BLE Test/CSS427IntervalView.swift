//
//  CSS427IntervalView.swift
//  CSS427Bluefruit_Connect
//
//  Created by George Urick on 3/7/16.
//  Copyright © 2016 Adafruit Industries. All rights reserved.
//

import UIKit

@objc protocol IntervalViewDelegate: Any {
    
    func sendRequest(command: String)
    
}

class CSS427IntervalView: UIView, UITextFieldDelegate {
    
    weak var delegate: IntervalViewDelegate?
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var tempLabel: UILabel!
    @IBOutlet weak var accelerometerLabel: UILabel!
    @IBOutlet weak var compassLabel: UILabel!
    
    @IBOutlet weak var distanceSampleField: UITextField!
    @IBOutlet weak var tempSampleField: UITextField!
    @IBOutlet weak var accelerometerSampleField: UITextField!
    @IBOutlet weak var compassSampleField: UITextField!
    
    @IBOutlet weak var distanceToggle: UIButton!
    @IBOutlet weak var tempToggle: UIButton!
    @IBOutlet weak var accelerometerToggle: UIButton!
    @IBOutlet weak var compassToggle: UIButton!
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        return true
    }
    
    func updateReading(printValue: String, device: Character) {
//        if containsACommand(reading) == false { return }
//        let letters = NSCharacterSet.letterCharacterSet()
//        let command = reading.substringToIndex(reading.startIndex.advancedBy(2))
//        var readString : String?
//        if reading.characters.count > 2 {
//            readString = reading.substringFromIndex(reading.startIndex.advancedBy(2))
//        }
//        
//        if (readString == nil){
//            checkToggle(command)
//            return
//        }
//        var index = 0;
//        for var c in readString!.unicodeScalars {
//            if letters.longCharacterIsMember(c.value) {
//                let newReading = readString!.substringFromIndex(readString!.startIndex.advancedBy(index))
//                readString = readString!.substringToIndex(readString!.startIndex.advancedBy(index))
//                print(newReading)
//                updateReading(newReading)
//                break;
//            }
//            index += 1
//        }
//        if (readString == nil || readString!.characters.count == 0) {
//            checkToggle(command)
//            return
//        }
        switch device {
        case "A":
            distanceLabel.text = "Distance: \(printValue) cm"
            break;
        case "B":
            tempLabel.text = "Temperature: \(printValue)°"
            break;
        case "C":
            accelerometerLabel.text = "Accelerometer: \(printValue)"
            break;
        case "D":
            compassLabel.text = "Compass: \(printValue)°"
            
        default:
            printLog(self, funcName: "updateReading", logString: "Incorrect command passed")
        }
    }
    
    func checkToggle(command: String) {
        switch command {
        case CommandEnableDistance:
            distanceToggle.setTitle("D", forState: .Normal)
            break;
        case CommandEnableTemp:
            tempToggle.setTitle("D", forState: .Normal)
            break;
        case CommandEnableAccelerometer:
            accelerometerToggle.setTitle("D", forState: .Normal)
            break;
        case CommandEnableCompass:
            compassToggle.setTitle("D", forState: .Normal)
            break;
        case CommandDisableDistance:
            distanceToggle.setTitle("E", forState: .Normal)
            break;
        case CommandDisableTemp:
            tempToggle.setTitle("E", forState: .Normal)
            break;
        case CommandDisableAccelerometer:
            accelerometerToggle.setTitle("E", forState: .Normal)
            break;
        case CommandDisableCompass:
            compassToggle.setTitle("E", forState: .Normal)
            break;
        default:
            break;
        }
    }
    
    func closeKeyboard() {
        self.distanceSampleField.resignFirstResponder()
        self.tempSampleField.resignFirstResponder()
        self.accelerometerSampleField.resignFirstResponder()
        self.compassSampleField.resignFirstResponder()
    }
    
    func clear() {
        distanceLabel.text = ""
        distanceToggle.setTitle("D", forState: .Normal)
        tempLabel.text = ""
        tempToggle.setTitle("D", forState: .Normal)
        accelerometerLabel.text = ""
        accelerometerToggle.setTitle("D", forState: .Normal)
        compassLabel.text = ""
        compassToggle.setTitle("D", forState: .Normal)
    }
    
    @IBAction func toggleDistance(sender: UIButton) {
        if delegate == nil { return }
        let command = distanceToggle.titleForState(.Normal) == "D" ? CommandDisableDistance : CommandEnableDistance
        delegate?.sendRequest(command)
    }
    
    @IBAction func toggleTemp(sender: UIButton) {
        if delegate == nil { return }
        let command = tempToggle.titleForState(.Normal) == "D" ? CommandDisableTemp : CommandEnableTemp
        delegate?.sendRequest(command)
        
    }
    
    @IBAction func toggleAccelerometer(sender: UIButton) {
        if delegate == nil { return }
        let command = accelerometerToggle.titleForState(.Normal) == "D" ? CommandDisableAccelerometer : CommandEnableAccelerometer
        delegate?.sendRequest(command)
    }
    
    @IBAction func toggleCompass(sender: UIButton) {
        if delegate == nil { return }
        let command = compassToggle.titleForState(.Normal) == "D" ? CommandDisableCompass : CommandEnableCompass
        delegate?.sendRequest(command)
    }
    
    
    @IBAction func updateDistanceSample(sender: UIButton) {
        closeKeyboard()
        if (delegate == nil) { return }
        delegate?.sendRequest("\(CommandAlertUpdateDistance)\(distanceSampleField.text!)")
        distanceSampleField.text = ""
    }
    
    @IBAction func updateTempSample(sender: UIButton) {
        closeKeyboard()
        if (delegate == nil) { return }
        delegate?.sendRequest("\(CommandAlertUpdateTemp)\(tempSampleField.text!)")
        tempSampleField.text = ""
    }
    
    @IBAction func updateAccelerometerSample(sender: UIButton) {
        closeKeyboard()
        if (delegate == nil) { return }
        delegate?.sendRequest("\(CommandAlertUpdateAccelerometer)\(accelerometerSampleField.text!)")
        accelerometerSampleField.text = ""
    }
    
    @IBAction func updateCompassSample(sender: UIButton) {
        closeKeyboard()
        if (delegate == nil) { return }
        delegate?.sendRequest("\(CommandAlertUpdateCompass)\(compassSampleField.text!)")
        compassSampleField.text = ""
    }
    
    
    
    /*
     // Only override drawRect: if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func drawRect(rect: CGRect) {
     // Drawing code
     }
     */
    
}
