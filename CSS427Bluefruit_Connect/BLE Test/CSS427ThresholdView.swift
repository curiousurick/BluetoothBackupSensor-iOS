//
//  CSS427ThresholdView.swift
//  CSS427Bluefruit_Connect
//
//  Created by George Urick on 3/11/16.
//  Copyright © 2016 Adafruit Industries. All rights reserved.
//

import UIKit

@objc protocol ThresholdViewDelegate: Any {
    
    func sendRequest(command: String)
    
}

class CSS427ThresholdView: UIView, UITextFieldDelegate {
    
    weak var delegate: ThresholdViewDelegate?
    
    @IBOutlet weak var distanceThresholdTextField: UITextField!
    @IBOutlet weak var tempThresholdTextField: UITextField!
    @IBOutlet weak var accelerometerThresholdTextField: UITextField!
    @IBOutlet weak var compassThresholdTextField: UITextField!
    
    
    @IBAction func sendDistanceClicked(sender: UIButton) {
        let value = self.distanceThresholdTextField.text!
        self.distanceThresholdTextField.text = ""
        if delegate == nil || value.characters.count == 0 { return }
        delegate?.sendRequest("VA\(value)")
    }
    @IBAction func sendTempClicked(sender: UIButton) {
        let value = self.tempThresholdTextField.text!
        self.tempThresholdTextField.text = ""
        if delegate == nil || value.characters.count == 0 { return }
        delegate?.sendRequest("VB\(value)")
    }
    
    @IBAction func sendAccelerometerClicked(sender: UIButton) {
        let value = self.accelerometerThresholdTextField.text!
        self.accelerometerThresholdTextField.text = ""
        if delegate == nil || value.characters.count == 0 { return }
        delegate?.sendRequest("VC\(value)")
    }
    
    @IBAction func sendCompassClicked(sender: UIButton) {
        let value = self.compassThresholdTextField.text!
        self.compassThresholdTextField.text = ""
        if delegate == nil || value.characters.count == 0 { return }
        delegate?.sendRequest("VD\(value)")
    }
    
    

}
