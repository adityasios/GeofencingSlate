//
//  ViewController.swift
//  GeofencingSlate
//
//  Created by Rakhi on 30/01/19.
//  Copyright © 2019 myself. All rights reserved.
//

import UIKit
import CoreLocation




class ViewController: UIViewController {
    
    let locationManager : CLLocationManager = CLLocationManager()
    
    // MARK: - VC LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        enableLocationServices()
    }
}





// MARK: - LOCATION MANAGER
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
            print("restricted")
            escalateLocationServiceAuthorization()
        case .authorizedAlways:
            print("authorizedAlways")
        //enableMyAlwaysFeatures()
        default:
            break
        }
    }
    
    func escalateLocationServiceAuthorization() {
        locationManager.requestAlwaysAuthorization()
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedAlways || status == CLAuthorizationStatus.authorizedWhenInUse) {
            print("authorizedAlways")
        }else if (status == CLAuthorizationStatus.denied){
            print("denied")
        }else if (status == CLAuthorizationStatus.notDetermined){
            print("notDetermined")
        }
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





