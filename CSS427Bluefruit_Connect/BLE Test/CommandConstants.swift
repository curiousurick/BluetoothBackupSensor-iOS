//
//  CommandConstants.swift
//  CSS427Bluefruit_Connect
//
//  Created by George Urick on 3/7/A6.
//  Copyright © 2016 Adafruit Industries. All rights reserved.
//

import UIKit

let CommandRequestDistance = "RA"
let CommandRequestTemp = "RB"
let CommandRequestAccelerometer = "RC"
let CommandRequestCompass = "RD"

let CommandIntervalDistance = "IA"
let CommandIntervalTemp = "IB"
let CommandIntervalAccelerometer = "IC"
let CommandIntervalCompass = "ID"

let CommandAlertDistance = "AA"
let CommandAlertTemp = "AB"
let CommandAlertAccelerometer = "AC"
let CommandAlertCompass = "AD"

let CommandAlertUpdateDistance = "UA"
let CommandAlertUpdateTemp = "UB"
let CommandAlertUpdateAccelerometer = "UC"
let CommandAlertUpdateCompass = "UD"

let CommandSampleUpdateDistance = "VA"
let CommandSampleUpdateTemp = "VB"
let CommandSampleUpdateAccelerometer = "VC"
let CommandSampleUpdateCompass = "VD"

let CommandEnableDistance = "EA"
let CommandEnableTemp = "EB"
let CommandEnableAccelerometer = "EC"
let CommandEnableCompass = "ED"

let CommandDisableDistance = "DA"
let CommandDisableTemp = "DB"
let CommandDisableAccelerometer = "DC"
let CommandDisableCompass = "DD"

func containsACommand(string: String) -> Bool {
    
    if (string.substringToIndex(string.startIndex.advancedBy(2)).containsString(CommandRequestDistance))
        || (string.containsString(CommandRequestDistance))
        || (string.containsString(CommandRequestTemp))
        || (string.containsString(CommandRequestAccelerometer))
        || (string.containsString(CommandRequestCompass))
        || (string.containsString(CommandIntervalDistance))
        || (string.containsString(CommandIntervalTemp))
        || (string.containsString(CommandIntervalAccelerometer))
        || (string.containsString(CommandIntervalCompass))
        || (string.containsString(CommandAlertDistance))
        || (string.containsString(CommandAlertTemp))
        || (string.containsString(CommandAlertAccelerometer))
        || (string.containsString(CommandAlertCompass))
        || (string.containsString(CommandAlertUpdateDistance))
        || (string.containsString(CommandAlertUpdateTemp))
        || (string.containsString(CommandAlertUpdateAccelerometer))
        || (string.containsString(CommandAlertUpdateCompass))
        || (string.containsString(CommandSampleUpdateDistance))
        || (string.containsString(CommandSampleUpdateTemp))
        || (string.containsString(CommandSampleUpdateAccelerometer))
        || (string.containsString(CommandSampleUpdateCompass))
        || (string.containsString(CommandEnableDistance))
        || (string.containsString(CommandEnableTemp))
        || (string.containsString(CommandEnableAccelerometer))
        || (string.containsString(CommandEnableCompass))
        || (string.containsString(CommandDisableDistance))
        || (string.containsString(CommandDisableTemp))
        || (string.containsString(CommandDisableAccelerometer)) ||
        (string.containsString(CommandDisableCompass)) {
        
        
        return true;
        
        
    }
    return false;
    
    
}