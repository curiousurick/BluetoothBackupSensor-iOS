# BluetoothBackupSensor-iOS
This app is forked from adafruit/Bluefruit_LE_Connect and was edited to connect to two bluetooth devices. 

One device, the "Sensor", will be periodically sending messages that the app will display. The "sensor" device is expected to send messages with prefixes and that will determine the action.

A\<Float\>: This is an alert message. The app will show an alert, vibrate, and make a sound. The alert will display the distance that the sensor is from something. The float will be the distance in CM. The app will also send this data to a receiver.

I\<Float\>: This is the measurement sent on an interval. This interval is determined on the Sensor.

R\<Float\>: This is the measurement sent on request. You can tap the request button to get the current reading.

The app will send messages as well. To the sensor, it will send:

E: This will enable interval readings.
D: This will disable interval readings.

To the receiver, it will send:

A\<Float\>: This tells the receiver that the sensor has come within the threshold distance from something.

This project was made for CSS 427, Introduction to Embedded Systems at UW Bothell.
