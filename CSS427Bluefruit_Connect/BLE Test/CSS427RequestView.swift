//
//  CSS427RequestView.swift
//  CSS427Bluefruit_Connect
//
//  Created by George Urick on 3/7/16.
//  Copyright © 2016 Adafruit Industries. All rights reserved.
//

import UIKit

@objc protocol RequestViewDelegate: Any {
    
    func sendRequest(command: String)
    
}

class CSS427RequestView: UIView {
    
    weak var delegate: RequestViewDelegate?
    @IBOutlet weak var requestDistanceButton: UIButton!
    @IBOutlet weak var requestTempButton: UIButton!
    @IBOutlet weak var requestAccelerometerButton: UIButton!
    @IBOutlet weak var requestCompassButton: UIButton!
    
    @IBOutlet weak var requestDistanceLabel: UILabel!
    @IBOutlet weak var requestTempLabel: UILabel!
    @IBOutlet weak var requestAccelerometerLabel: UILabel!
    @IBOutlet weak var requestCompassLabel: UILabel!
    
    func updateReading(printValue: String, device: Character) {
        
        
        
        switch device {
        case "A":
            self.requestDistanceLabel.text = "\(printValue) cm"
            break;
        case "B":
            self.requestTempLabel.text = "\(printValue)°"
            break;
        case "C":
            self.requestAccelerometerLabel.text = "\(printValue)"
            break;
        case "D":
            self.requestCompassLabel.text = "\(printValue)°"
            break;
        default:
            printLog(self, funcName: "updateReading", logString: "Invalid command")
            break;
        }
    }
    
    func clear() {
        requestDistanceLabel.text = ""
        requestTempLabel.text = ""
        requestAccelerometerLabel.text = ""
        requestCompassLabel.text = ""
    }
    
    
    @IBAction func requestDistanceClicked(sender: AnyObject) {
        if delegate == nil {
            return
        }
        delegate?.sendRequest(CommandRequestDistance)
    }
    
    @IBAction func requestTemperatureClicked(sender: AnyObject) {
        if delegate == nil {
            return
        }
        delegate?.sendRequest(CommandRequestTemp)
    }
    
    @IBAction func requestAccelerometerClicked(sender: AnyObject) {
        if delegate == nil {
            return
        }
        delegate?.sendRequest(CommandRequestAccelerometer)
    }
    
    @IBAction func requestCompassClicked(sender: AnyObject) {
        if delegate == nil {
            return
        }
        delegate?.sendRequest(CommandRequestCompass)
    }
}
