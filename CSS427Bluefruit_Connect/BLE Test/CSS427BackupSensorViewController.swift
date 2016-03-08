//
//  CSS427BackupSensorViewController.swift
//  Adafruit Bluefruit LE Connect
//
//  Created by George Urick on 2/24/16.
//  Copyright © 2016 Adafruit Industries. All rights reserved.
//

import Foundation
import UIKit
import AudioToolbox
import Dispatch

protocol CSS427BackupSensorDelegate: HelpViewControllerDelegate {
    
    func sendData(newData:NSData, uuid: String)
    
}


class CSS427BackupSensorViewController: UIViewController, MqttManagerDelegate {
    
    private var sensorID: String?
    private var receiverID: String?
    
    
    
    var delegate: CSS427BackupSensorDelegate?
    @IBOutlet var helpViewController:HelpViewController!
    @IBOutlet weak var currentReadingView: UILabel!
    
    @IBOutlet weak var requestedReadingView: UILabel!
    
    @IBOutlet weak var requestReadingButton: UIButton!
    @IBOutlet weak var toggleIntervalButton: UIButton!
    
    var intervalReadingsEnabled = true
    
    private let backgroundQueue : dispatch_queue_t = dispatch_queue_create("com.adafruit.bluefruitconnect.bgqueue", nil)
    
    private let notificationCommandString = "N!"

    override func viewDidLoad() {
        super.viewDidLoad()
        

        let mqttManager = MqttManager.sharedInstance
        if (MqttSettings.sharedInstance.isConnected) {
            mqttManager.delegate = self
            mqttManager.connectFromSavedSettings()
        }
        
        
        // Do any additional setup after loading the view.
    }
    
    func setupBluetoothDevices(sensor: String?, receiver: String?) {
        sensorID = sensor
        receiverID = receiver
    }
    
    
    func showAlert(distance: Float) {
            sendUartMessage("A", wasReceivedFromMqtt: false, uuid: receiverID)
        
//        let distanceMessage = String(format: "You are approaching another object.\nYou are %.2f cm from another object", arguments: [distance])
//        
//        let alertController = UIAlertController(title: "SLOW DOWN!", message: distanceMessage, preferredStyle: .Alert)
//        
//        let action = UIAlertAction(title: "OK", style: .Default) { (action) in
//        }
//        alertController.addAction(action)
//        
//        self.presentViewController(alertController, animated: true) { 
//            //play alarm sound
//            AudioServicesPlaySystemSound(1005);
//            
//        }
    }
    
    func updateCurrentReadingView(distance: Float) {
        currentReadingView.text = "\(distance) cm"
    }
    
    func updateRequestedReadingView(distance: Float) {
        requestedReadingView.text = "\(distance) cm"
    }
    
    
    @IBAction func requestReading(sender: AnyObject) {
        let queryMessage = NSString(string: "R")
        sendUartMessage(queryMessage, wasReceivedFromMqtt: false, uuid: sensorID)
    }
    
    @IBAction func toggleIntervalReadings(sender: AnyObject) {
        var queryMessage: NSString?
        if intervalReadingsEnabled {
            queryMessage = NSString(string: "D")
        }
        else {
            queryMessage = NSString(string: "E")
        }
        sendUartMessage(queryMessage!, wasReceivedFromMqtt: false, uuid: sensorID)
        
    }
    
    func sendUartMessage(message: NSString, wasReceivedFromMqtt: Bool, uuid: String?) {
        // MQTT publish to TX
        let mqttSettings = MqttSettings.sharedInstance
        if(mqttSettings.isPublishEnabled) {
            if let topic = mqttSettings.getPublishTopic(MqttSettings.PublishFeed.TX.rawValue) {
                let qos = mqttSettings.getPublishQos(MqttSettings.PublishFeed.TX.rawValue)
                MqttManager.sharedInstance.publish(message as String, topic: topic, qos: qos)
            }
        }
        
        if ((!wasReceivedFromMqtt || mqttSettings.subscribeBehaviour == .Transmit)) {
            if (uuid != nil) {
                let data = NSData(bytes: message.UTF8String, length: message.length)
                delegate?.sendData(data, uuid: uuid!)
            }
        }
    }
    
    func updateConsoleWithIncomingData(newData:NSData) {
        
        //Write new received data to the console text view
        dispatch_async(backgroundQueue, { () -> Void in
            //convert data to string & replace characters we can't display
            let dataLength:Int = newData.length
            var data = [UInt8](count: dataLength, repeatedValue: 0)
            
            newData.getBytes(&data, length: dataLength)
            
            for index in 0...dataLength-1 {
                if (data[index] <= 0x1f) || (data[index] >= 0x80) { //null characters
                    if (data[index] != 0x9)       //0x9 == TAB
                        && (data[index] != 0xa)   //0xA == NL
                        && (data[index] != 0xd) { //0xD == CR
                        data[index] = 0xA9
                    }
                }
            }
            
            
            let newString = NSString(bytes: &data, length: dataLength, encoding: NSUTF8StringEncoding)
            let newSwiftString = newString as! String
            
            printLog(self, funcName: "updateConsoleWithIncomingData", logString: newSwiftString)
            
            //Check for notification command & send if needed
            if newString!.containsString(self.notificationCommandString) == true {
                printLog(self, funcName: "Checking for notification", logString: "does contain match")
                let msgString = newString!.stringByReplacingOccurrencesOfString(self.notificationCommandString, withString: "")
                self.sendNotification(msgString)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                let printableString = newSwiftString.substringFromIndex(newSwiftString.startIndex.advancedBy(1))
                let distance = Float(printableString)
                let command = newSwiftString[newSwiftString.startIndex]
                if command == "R" {
                    if (distance != nil) {
                        self.updateRequestedReadingView(distance!)
                    }
                }
                else if command == "I" {
                    if (distance != nil) {
                        self.updateCurrentReadingView(distance!)
                    }
                }
                else if command == "A" {
                    if (distance != nil) {
                        self.showAlert(distance!)
                    }
                }
                else if command == "D" {
                    self.intervalReadingsEnabled = false
                    self.toggleIntervalButton.setTitle("Enable Interval Readings", forState: .Normal)
                }
                else if command == "E" {
                    self.intervalReadingsEnabled = true
                    self.toggleIntervalButton.setTitle("Disable Interval Readings", forState: .Normal)
                }
                else {
                    printLog(self, funcName: "updateConsoleWithIncomingData", logString: "Invalid command received")
                }
            })
        })
    }
    
    func resetUI() {
        if (currentReadingView != nil) {
            currentReadingView.text = ""
        }
        if (requestedReadingView != nil) {
            requestedReadingView.text = ""
        }
        
    }
    
    func receiveData(newData: NSData) {
        if (isViewLoaded() && view.window != nil) {
            
            let mqttSettings = MqttSettings.sharedInstance
            if (mqttSettings.isPublishEnabled) {
                if let message = NSString(data: newData, encoding: NSUTF8StringEncoding) {
                    if let topic = mqttSettings.getPublishTopic(MqttSettings.PublishFeed.RX.rawValue) {
                        let qos = mqttSettings.getPublishQos(MqttSettings.PublishFeed.RX.rawValue)
                        MqttManager.sharedInstance.publish(message as String, topic: topic, qos: qos)
                    }
                }
            }
            
            updateConsoleWithIncomingData(newData)
        }
    }
    
    func didConnect() {
        resetUI()
    }
    
    func onMqttMessageReceived(message: String, topic: String) {
        dispatch_async(dispatch_get_main_queue(), { [unowned self] in
            
            self.sendUartMessage((message as NSString), wasReceivedFromMqtt: true, uuid: self.sensorID)
        })
    }
    
    func onMqttConnected() {
        dispatch_async(dispatch_get_main_queue(), { [unowned self] in
            
            self.updateMqttStatus()
        })
    }
    
    func onMqttDisconnected() {
        dispatch_async(dispatch_get_main_queue(), { [unowned self] in
            self.updateMqttStatus()
        })
    }
    
    func onMqttError(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func updateMqttStatus() {
        //It's all just UI stuff I don't give a shit about.
//        if let imageView = mqttBarButtonItemImageView {
//            let status = MqttManager.sharedInstance.status
//            let tintColor = self.view.tintColor
//            
//            switch (status) {
//            case .Connecting:
//                let imageFrames = [
//                    UIImage(named:"mqtt_connecting1")!.tintWithColor(tintColor),
//                    UIImage(named:"mqtt_connecting2")!.tintWithColor(tintColor),
//                    UIImage(named:"mqtt_connecting3")!.tintWithColor(tintColor)
//                ]
//                imageView.animationImages = imageFrames
//                imageView.animationDuration = 0.5 * Double(imageFrames.count)
//                imageView.animationRepeatCount = 0;
//                imageView.startAnimating()
//                
//            case .Connected:
//                imageView.stopAnimating()
//                imageView.image = UIImage(named:"mqtt_connected")!.tintWithColor(tintColor)
//                
//            default:
//                imageView.stopAnimating()
//                imageView.image = UIImage(named:"mqtt_disconnected")!.tintWithColor(tintColor)
//            }
//        }
    }
    
    
    func sendNotification(msgString:String) {
        
        let note = UILocalNotification()
        //        note.fireDate = NSDate().dateByAddingTimeInterval(2.0)
        //        note.fireDate = NSDate()
        note.alertBody = msgString
        note.soundName =  UILocalNotificationDefaultSoundName
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            UIApplication.sharedApplication().presentLocalNotificationNow(note)
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
