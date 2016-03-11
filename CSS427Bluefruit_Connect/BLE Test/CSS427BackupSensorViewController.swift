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


class CSS427BackupSensorViewController: UIViewController, MqttManagerDelegate, RequestViewDelegate, IntervalViewDelegate, ThresholdViewDelegate {
    
    private var sensorID: String?
    private var receiverID: String?
    
    
    var delegate: CSS427BackupSensorDelegate?
    @IBOutlet var helpViewController:HelpViewController!
    @IBOutlet weak var intervalReadingView: CSS427IntervalView!
    @IBOutlet weak var requestReadingView: CSS427RequestView!
    @IBOutlet weak var thresholdView: CSS427ThresholdView!
    
    private let backgroundQueue : dispatch_queue_t = dispatch_queue_create("com.adafruit.bluefruitconnect.bgqueue", nil)
    
    private let notificationCommandString = "N!"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.intervalReadingView.delegate = self
        self.requestReadingView.delegate = self
        self.thresholdView.delegate = self
        
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
    
    func sendRequest(command: String) {
        sendUartMessage(command, wasReceivedFromMqtt: false, uuid: sensorID)
    }
    
    var alertShowing = false
    var allowAlerts = true
    
    func showAlert(reading: String, device: Character) {
        //TODO FIX THIS
        if !alertShowing && allowAlerts {
            alertShowing = true
            var alertMessage: String?
            switch device {
            case "A":
                alertMessage = "You are approaching another object.\nYou are \(reading) cm from another object"
                break;
            case "B":
                alertMessage = "Wow it's really hot or cold! \nTemperature is \(reading)°"
                break;
            case "C":
                alertMessage = "Really wonky angles! \(reading)"
                break;
            case "D":
                alertMessage = "You are really good at reading a compass! \(reading)°"
                break;
            default:
                printLog(self, funcName: "showAlert", logString: "Invalid device to show alert")
            }
            if alertMessage == nil { return }
            
            let alertController = UIAlertController(title: "ALERT!", message: alertMessage, preferredStyle: .Alert)
            
            let action = UIAlertAction(title: "OK", style: .Default) { (action) in
                self.alertShowing = false
            }
            let stopAction = UIAlertAction(title: "STOP!!", style: .Destructive, handler: { (action) in
                self.allowAlerts = false
            })
            alertController.addAction(action)
            alertController.addAction(stopAction)
            
            self.presentViewController(alertController, animated: true) {
                //play alarm sound
                AudioServicesPlaySystemSound(1005);
            }
            
        }
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        intervalReadingView.closeKeyboard()
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
    
    func updateConsoleWithIncomingData(newStringInput:String) {
        
        var newString = newStringInput.stringByReplacingOccurrencesOfString("\r", withString: "")
        newString = newString.stringByReplacingOccurrencesOfString("\n", withString: "")
        
        printLog(self, funcName: "updateConsoleWithIncomingData", logString: newString)
        if newString.characters.count < 2 { return }
        //Check for notification command & send if needed
        if newString.containsString(self.notificationCommandString) == true {
            printLog(self, funcName: "Checking for notification", logString: "does contain match")
            let msgString = newString.stringByReplacingOccurrencesOfString(self.notificationCommandString, withString: "")
            self.sendNotification(msgString)
        }
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            self.updateReading(newString)
            
        })
    }
    
    func updateReading(newString: String) {
        if containsACommand(newString) == false { return }
        let command = newString[newString.startIndex]
        let letters = NSCharacterSet.letterCharacterSet()
        //let command = reading.substringToIndex(reading.startIndex.advancedBy(2))
        var readString: String?
        if newString.characters.count > 2 {
            readString = newString.substringFromIndex(newString.startIndex.advancedBy(2))
        }
        if (readString == nil) {
            self.intervalReadingView.checkToggle(newString.substringToIndex(newString.startIndex.advancedBy(2)))
            self.sendUartMessage(newString, wasReceivedFromMqtt: false, uuid: self.receiverID)
            return
        }
        var index = 0;
        for var c in readString!.unicodeScalars {
            if letters.longCharacterIsMember(c.value) {
                let char = readString![readString!.startIndex.advancedBy(index)]
                if char == "X" || char == "Y" || char == "Z" {
                    index += 1
                    continue
                }
                let newReading = readString!.substringFromIndex(readString!.startIndex.advancedBy(index))
                readString = readString!.substringToIndex(readString!.startIndex.advancedBy(index))
                print(newReading)
                updateReading(newReading)
                break;
            }
            index += 1
        }
        if (readString == nil || readString!.characters.count == 0) {
            self.intervalReadingView.checkToggle(newString.substringToIndex(newString.startIndex.advancedBy(2)))
             self.sendUartMessage(newString, wasReceivedFromMqtt: false, uuid: self.receiverID)
            return
        }
        let device = newString[newString.startIndex.advancedBy(1)]

        switch command {
        case "R":
            self.requestReadingView.updateReading(readString!, device: device)
            let thing = "R\(device)\(readString!)"
            self.sendUartMessage(thing, wasReceivedFromMqtt: false, uuid: self.receiverID)
            break;
        //Interval
        case "I":
            self.intervalReadingView.updateReading(readString!, device: device)
            let thing = "I\(device)\(readString!)"
            self.sendUartMessage(thing, wasReceivedFromMqtt: false, uuid: self.receiverID)
            break;
        //Alarm
        case "A":
            let thing = "A\(device)\(readString!)"
            self.sendUartMessage(thing, wasReceivedFromMqtt: false, uuid: self.receiverID)
            self.showAlert(readString!, device: device)
            
            break;
        default:
            printLog(self, funcName: "updateConsoleWithIncomingData", logString: "Invalid command received")
            break;
            
        }
    }
    
    func resetUI() {
        if (intervalReadingView != nil) {
            intervalReadingView.clear()
        }
        if (requestReadingView != nil) {
            requestReadingView.clear()
        }
        
    }
    
    func receiveData(newData: NSData, uuid: String) {
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
                if uuid == self.receiverID! {
                    self.sendUartMessage("Q", wasReceivedFromMqtt: false, uuid: self.sensorID)
                }
                else if uuid == self.sensorID! {
                    let newString = NSString(bytes: &data, length: dataLength, encoding: NSUTF8StringEncoding)
                    let newSwiftString = newString as! String
                    
                    self.updateConsoleWithIncomingData(newSwiftString)
//                    self.sendUartMessage(newSwiftString, wasReceivedFromMqtt: false, uuid: self.receiverID)
//                    self.sendUartMessage("Q", wasReceivedFromMqtt: false, uuid: self.receiverID)
                }
            })
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
