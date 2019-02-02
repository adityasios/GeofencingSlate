//
//  ViewController.swift
//  GeofencingSlate
//
//  Created by Rakhi on 30/01/19.
//  Copyright © 2019 myself. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit



class ViewController: UIViewController {
    
    @IBOutlet weak var barSetting: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager : CLLocationManager = CLLocationManager()
    
    
    // MARK: - VC LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initMethod()
    }
    
    private func initMethod() {
        enableLocationServices()
    }
    
    
    // MARK: - ACTION METHOD
    @IBAction func btnSettingClicked(_ sender: UIBarButtonItem) {
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            getAlert(titletop: "Error", subtitle: "Please Enable Location Service From Device Settings", tag: 10)
            return
        }
        
        let set = storyboard?.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        navigationController?.pushViewController(set, animated: true)
    }
}





// MARK: - LOCATION METHODS
extension ViewController : CLLocationManagerDelegate {
    
    
    private func enableLocationServices() {
        
        if !CLLocationManager.locationServicesEnabled() {
            getAlert(titletop: "Error", subtitle: "Please Enable Location Service From Device Settings", tag: 10)
            return
        }
        
        locationManager.delegate = self
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            print("notDetermined")
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            print("restricted")
            self.getAlert(titletop: "Error", subtitle: "Please Enable Location Service From App Settings", tag: 10)
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
            startReceivingLocationChanges()
        case .authorizedAlways:
            print("authorizedAlways")
            startReceivingLocationChanges()
       
        default:
            break
        }
    }
    
    
    private func startReceivingLocationChanges() {
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedWhenInUse && authorizationStatus != .authorizedAlways {
            print("User has not authorized access to location information")
            return
        }
        
        
        // Configure and start the service.
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.distanceFilter = 100.0  // In meters.
        locationManager.startUpdatingLocation()
    }
    
    
    private func escalateLocationServiceAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    
    
    
   
    
    
    
    private func setMapViewRegion(last:CLLocation) {
        
        let startCoord : CLLocationCoordinate2D = last.coordinate
        print("map centre (\(startCoord.latitude) \(startCoord.longitude))")
        
        var region = MKCoordinateRegion.init(center: startCoord, latitudinalMeters: 100, longitudinalMeters: 100)
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
    
    
    // MARK: - LOCATION DELEGATES
    private func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedAlways) {
            print("didChangeAuthorization - authorizedAlways")
            startReceivingLocationChanges()
        }else if (status == CLAuthorizationStatus.authorizedWhenInUse){
            print("didChangeAuthorization - authorizedWhenInUse")
            startReceivingLocationChanges()
        }else if (status == CLAuthorizationStatus.denied){
            print("didChangeAuthorization - denied")
        }else if (status == CLAuthorizationStatus.notDetermined){
            print("didChangeAuthorization - notDetermined")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        setMapViewRegion(last: lastLocation)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            manager.stopUpdatingLocation()
            return
        }
        // Notify the user of any errors.
    }
}




// MARK: - ALERT MANAGER
extension ViewController  {
    
    func getAlert(titletop:String,subtitle:String,tag:Int){
        
        let AC = UIAlertController(title: titletop, message: subtitle, preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
        })
        AC.addAction(okBtn)
        
        let setBtn = UIAlertAction(title: "Settings", style: .default, handler: {(_ action: UIAlertAction) -> Void in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        AC.addAction(setBtn)
        self.present(AC, animated: true, completion:nil)
    }
}





















