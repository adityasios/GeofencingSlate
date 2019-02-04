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
import SystemConfiguration.CaptiveNetwork



class ViewController: UIViewController {
    
    @IBOutlet weak var barSetting: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    let locationManager : CLLocationManager = CLLocationManager()
    var geoMain = GeoMod()
    
    
    
    // MARK: - VC LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initMethod()
    }
    
    
    private func initMethod() {
        enableLocationServices()
        
        //reset monitor saved region
        if !locationManager.monitoredRegions.isEmpty {
            if let reg = locationManager.monitoredRegions.first?.identifier , reg == Helper.geoReg {
                locationManager.stopMonitoring(for: locationManager.monitoredRegions.first!)
            }
        }
    }
    
    
    // MARK: - ACTION METHOD
    @IBAction func btnSettingClicked(_ sender: UIBarButtonItem) {
        
        let authorizationStatus = CLLocationManager.authorizationStatus()
        if authorizationStatus != .authorizedAlways {
            getAlert(titletop: "Error", subtitle: "Please Enable Location Service From Device Settings \n For Geo Monitoring Always Autorization Requires", tag: 20)
            return
        }
        let set = storyboard?.instantiateViewController(withIdentifier: "SettingVC") as! SettingVC
        set.delegateSetSetting = self
        set.geo = geoMain
        navigationController?.pushViewController(set, animated: true)
    }
    
    
    
    @IBAction func btnStatusClicked(_ sender: UIButton) {
        
        //NOTE - : we can use geoMain.isGeoInside to get status which in turns updated in didExitRegion , didEnterRegion & didDetermineState state:for region - i have implemented these delegate just to show that approach
        
        if geoMain.isMonitoring {
            if let loc = locationManager.location,let rad = geoMain.geoRadius,let lat = geoMain.geolat,let lon = geoMain.geolon  {
                let coordCentre = CLLocation(latitude: lat, longitude: lon)
                let distanceInMeters =  coordCentre.distance(from: loc)
                if Int(distanceInMeters) < rad {
                    Helper.getAlert(view: self, titletop: "Status - Inside Geo Fence", subtitle: "Geographically Inside the monitoring Region")
                }else{
                    
                    //wifi name
                    if let wifi = geoMain.wifiName {
                        
                        //get connected wifi name
                        var ssid: String?
                        if let interfaces = CNCopySupportedInterfaces() as NSArray? {
                            for interface in interfaces {
                                if let interfaceInfo = CNCopyCurrentNetworkInfo(interface as! CFString) as NSDictionary? {
                                    ssid = interfaceInfo[kCNNetworkInfoKeySSID as String] as? String
                                    break
                                }
                            }
                        }
                        
                        
                        if let ssid_ne = ssid,ssid_ne == wifi{
                            Helper.getAlert(view: self, titletop: "Status - Inside GeoFence", subtitle: "Geographically Outside the monitoring Region but connected to wifi \(ssid!)")
                        }else{
                            Helper.getAlert(view: self, titletop: "Status - Outside GeoFence", subtitle: "Geographically Outside the monitoring Region")
                        }
                    }else{
                        Helper.getAlert(view: self, titletop: "Status - Outside GeoFence", subtitle: "Geographically Outside the monitoring Region")
                    }
                }
            }
        }else{
            Helper.getAlert(view: self, titletop: "Aler", subtitle: "No Monitoring Region Currently Active.")
        }
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
            locationManager.requestAlwaysAuthorization()
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
    
    private func setMapViewRegion(last:CLLocationCoordinate2D) {
        var region = MKCoordinateRegion.init(center: last, latitudinalMeters: 100, longitudinalMeters: 100)
        if let rad = geoMain.geoRadius {
            region = MKCoordinateRegion.init(center: last, latitudinalMeters: CLLocationDistance(rad*2), longitudinalMeters: CLLocationDistance(rad*2))
        }
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
    
    // MARK: - LOCATION DELEGATES
    private func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == CLAuthorizationStatus.authorizedAlways) {
            startReceivingLocationChanges()
        }else if (status == CLAuthorizationStatus.authorizedWhenInUse){
            startReceivingLocationChanges()
        }else if (status == CLAuthorizationStatus.denied){
        }else if (status == CLAuthorizationStatus.notDetermined){
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        if  !geoMain.isMonitoring {
            setMapViewRegion(last: lastLocation.coordinate)
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if let error = error as? CLError, error.code == .denied {
            manager.stopUpdatingLocation()
            return
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didStartMonitoringFor region: CLRegion) {
        
        //set mk circle on map
        if region.identifier == Helper.geoReg {
            geoMain.isMonitoring = true
            locationManager.requestState(for: region)
            setMapMonitorRegion(geoMain)
        }
    }
    
    
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if region.identifier == Helper.geoReg {
            geoMain.isGeoInside = false
            print("didExitRegion")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if region.identifier == Helper.geoReg {
            geoMain.isGeoInside = true
            print("didEnterRegion")
        }
    }
    
    
    
    
    
    
    
    
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        switch state {
        case .inside:
            geoMain.isGeoInside = true
            print("inside")
        case .outside:
            geoMain.isGeoInside = false
            print("outside")
        case .unknown:
            print("unknown")
            
        default:
            break
        }
    }
}






// MARK: - MKMapViewDelegate
extension ViewController:MKMapViewDelegate{
    
    private func setMapMonitorRegion(_ geod: GeoMod){
        
        //remove pre annot
        let arrAnot = mapView.annotations.filter { $0 !== mapView.userLocation }
        if !arrAnot.isEmpty {
            mapView.removeAnnotations( arrAnot )
        }
        
        //add new annot
        let annotation = MKPointAnnotation()
        let geoC = CLLocationCoordinate2DMake(geod.geolat!,geod.geolon!)
        annotation.coordinate = geoC
        annotation.title = "Centre"
        annotation.subtitle = geod.geoAdd ?? "Monitoring region centre point"
        mapView.addAnnotation(annotation)
        
        //remove overlays
        if let overlays = mapView?.overlays {
            mapView.removeOverlays(overlays)
        }
        
        //add overlays
        let mkCir = MKCircle.init(center: geoC, radius: CLLocationDistance(geod.geoRadius!))
        mapView.addOverlay(mkCir)
        
        
        //map region
        setMapViewRegion(last: geoC)
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard overlay is MKCircle else {return MKOverlayRenderer()}
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.orange.withAlphaComponent(0.2)
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 2
        return renderer
    }
    
    func mapView(_ mapView: MKMapView,viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKPointAnnotation {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pincentre")
            pinAnnotationView.pinTintColor = .red
            pinAnnotationView.isDraggable = false
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            return pinAnnotationView
        }
        return nil
    }
}




// MARK: - SetCentreDelegate
extension ViewController:SetSettingVCDelegate  {
    func setRegionMonitring(_ geod: GeoMod){
        
        
        //set model
        geoMain = geod
       
        //monitor region start
        let geoC = CLLocationCoordinate2DMake(geod.geolat!,geod.geolon!)
        let geoRegion = CLCircularRegion(center: geoC, radius: CLLocationDistance(geod.geoRadius!), identifier:Helper.geoReg);
        geoRegion.notifyOnExit = true
        geoRegion.notifyOnEntry = true
        locationManager.startMonitoring(for: geoRegion)
    }
}





/*
 for region in locationManager.monitoredRegions {
 guard let circularRegion = region as? CLCircularRegion, circularRegion.identifier == geotification.identifier else { continue }
 locationManager.stopMonitoring(for: circularRegion)
 }*/






// MARK: - ALERT MANAGER
extension ViewController  {
    
    func getAlert(titletop:String,subtitle:String,tag:Int){
        
        let AC = UIAlertController(title: titletop, message: subtitle, preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
            if tag == 20 {
                self.escalateLocationServiceAuthorization()
            }
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























