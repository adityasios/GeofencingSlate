OBJECTIVE
--------------
iOS application that will detect if the device is located inside of a geofence area.
Application activity should provide controls to configure the geofence area and display current status: inside OR outside.


Geofence area -  is defined as a combination of 
some geographic point, radius, 
& specific Wifi network name.

A device is considered to be inside of the geofence area if the device 
is connected to the specified WiFi network 
or remains geographically inside the defined circle.

Note that if device coordinates are reported outside of the zone, but the device still connected to the specific Wifi network, then the device is treated as being inside the geofence area.




APP FLOW
-------------
4 screens - 

1.Monitoring
1.1 Check status of currently monitored region by clicking on bottom button "Check Status"
1.2 Map shows - user current location & region (if there)

2.Settings
2.1 Map View In Header - Shows user current location &  region (if there) using MKCircle
2.2 Set Monitoring Region Centre - on didselect user navigates to Add Centre Screen / display selected centre address
2.3 Set Monitoring Region  Radius - on didselect user navigates to Add Radius Screen / display selected radius in metres
2.4 Set Monitoring Wifi (Optional) - on didselect open popup to enter Wifi SSID ( network name) / display entred Wifi SSID 
2.5 Save (right bar buton item) - It will start monitoring the region 


3.SetCentre -  (Settings->SetCentre )
3.1 Map View In Centre - Shows user current location & red annotation displaying selected centre
3.2 Red Point Annotation - selected centre point , click on it it will shows popup with selected address
3.3 Search Region - On tapping it will present google autocomplete for searching location (centre point of geo fence)
3.4 Save - to save selected center & navigate back to setting

4.SetRadiusVC -  (Settings->SetRadiusVC )
4.1 Textfield to enter geo fence radius in Meters
4.2 Also lbl indicate maximum distance which can be set
4.3 Save - to save selected radius & navigate back to setting


NEXT STEPS - (not  implemented  in this build)
--------------
1.Currently app doesnt save geo fence region i.e once app is terminated & launched again user need to steup monitoring region again & also then delete option will be required for saved Geo fence region
It can be implemented  by saving Geomod in NSUserDfault in data form & then retriveing back by addhering it to Codable Protocol






HOW TO TEST APP
-----------------------
App should be tested on device as in simulator code to detect current wifi name doesn't work

Use Bundle id : com.sl.geotester (need to be registred with your apple developer account)
Also as app uses autocomplete where API key is linked to bundle id - com.sl.geo (current bundle ) which in turn is registred to my apple developer account 
so to install app you can use bundle id "com.sl.geotester" which i have also added for same Google API key

If you face any difficulity please feel free to contact






















