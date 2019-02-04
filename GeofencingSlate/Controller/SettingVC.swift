//
//  SettingVC.swift
//  GeofencingSlate
//
//  Created by Rakhi on 01/02/19.
//  Copyright © 2019 myself. All rights reserved.
//


import UIKit
import MapKit

protocol SetSettingVCDelegate: class {
    func setRegionMonitring(_ geod: GeoMod)
}


class SettingVC: UITableViewController {
    
    var geo = GeoMod()
    weak var delegateSetSetting: SetSettingVCDelegate?
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblCentre: UILabel!
    @IBOutlet weak var lblRadius: UILabel!
    @IBOutlet weak var lblWifi: UILabel!
    
    // MARK: - VC LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initMethod()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        sizeHeaderToFit()
    }
    
    
    
    // MARK: - INIT METHOD
    private func initMethod() {
        title = "Settings"
        if let cord = mapView.userLocation.location {
            setMapViewRegion(loc: cord.coordinate)
        }
    }
    
    private func setMapViewRegion(loc:CLLocationCoordinate2D) {
        var region = MKCoordinateRegion.init(center: loc, latitudinalMeters: 100, longitudinalMeters: 100)
        if let rad = geo.geoRadius {
            region = MKCoordinateRegion.init(center: loc, latitudinalMeters: CLLocationDistance(rad*2), longitudinalMeters: CLLocationDistance(rad*2))
        }
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
    
    
    // MARK: - SET UI
    private func setUI() {
        setMapMonitorRegion()
    }
    
    
    
    
    
    private func sizeHeaderToFit() {
        
        let headerView = tableView.tableHeaderView!
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let height =  ScreenSize.SCREEN_HEIGHT - 5.5*50
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        tableView.tableHeaderView = headerView
    }
    
    // MARK: - BUTTON ACTION
    @IBAction func btnSaveClicked(_ sender: UIBarButtonItem) {
        guard let lat = geo.geolat ,let lon = geo.geolat ,let rad =  geo.geoRadius else {
            Helper.getAlert(view: self, titletop: "Error", subtitle: "Please set mandatory fields (Centre & Radius) for geo monitoring")
            return
        }
        
        delegateSetSetting?.setRegionMonitring(geo)
        navigationController?.popViewController(animated: true)
    }
    
    
    
    
    // MARK: - TBLV DELEGATE
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let set = storyboard?.instantiateViewController(withIdentifier: "SetCentre") as! SetCentre
            set.delegateSetCentre = self
            set.geoPass = geo
            navigationController?.pushViewController(set, animated: true)
        }else if indexPath.row == 1 {
            let set = storyboard?.instantiateViewController(withIdentifier: "SetRadiusVC") as! SetRadiusVC
            set.delegateRadCentre = self
            set.geoPass = geo
            navigationController?.pushViewController(set, animated: true)
        }else if indexPath.row == 2 {
            setWifiSettingAlert()
        }
    }
}



// MARK: - CUSTOM DELEGATES
extension SettingVC: SetCentreDelegate,SetRadiusDelegate {
    
    func setCentreMonitring(_ geod: GeoMod) {
        geo.geolat = geod.geolat
        geo.geolon = geod.geolon
        geo.geoAdd = geod.geoAdd
        setMapMonitorRegion()
    }
    
    
    
    func setRadiusMonitring(_ radius: Int?){
        geo.geoRadius = radius
        lblRadius.text = "\(geo.geoRadius!) metres"
        setMapMonitorRegion()
    }
    
    
    func setMapMonitorRegion(){
        
        if let lat = geo.geolat,let lon = geo.geolon,let add = geo.geoAdd {
            lblCentre.text = "\(add)"
            setAnnotationOnMap(CLLocationCoordinate2D.init(latitude: lat, longitude: lon))
            
            
            if let rad = geo.geoRadius {
                
                lblRadius.text = "\(rad) metres"
                
                //remove overlays
                if let overlays = mapView?.overlays {
                    mapView.removeOverlays(overlays)
                }
                
                //add overlays
                let loc = CLLocationCoordinate2D.init(latitude: lat, longitude: lon)
                let mkCir = MKCircle.init(center: loc, radius: CLLocationDistance(rad))
                mapView.addOverlay(mkCir)
            }
        }
        
        
        //wifi name
        if let wifi = geo.wifiName {
            self.lblWifi.text = wifi
        }
    }
}






// MARK: - DELEGATES
extension SettingVC : MKMapViewDelegate {

    private func setAnnotationOnMap(_ locP: CLLocationCoordinate2D){
        
        //remove pre
        let arrAnot = mapView.annotations.filter { $0 !== mapView.userLocation }
        if !arrAnot.isEmpty {
            mapView.removeAnnotations( arrAnot )
        }
        
        //add new
        let annotation = MKPointAnnotation()
        annotation.coordinate = locP
        annotation.title = "Centre"
        annotation.subtitle = geo.geoAdd ?? "Monitoring region centre point"
        mapView.addAnnotation(annotation)
        
        //map region
        setMapViewRegion(loc: locP)
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
    
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        guard overlay is MKCircle else {return MKOverlayRenderer()}
        
        
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.orange.withAlphaComponent(0.2)
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 2
        return renderer
    }
}



// MARK: - SETTING WIFI
extension SettingVC  {
    private func setWifiSettingAlert(){
        
        let alertController = UIAlertController(title: "Wifi Name (SSID)", message: "Please enter your wifi name which will be check during monitoring", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Wifi SSID"
            if let wifi = self.geo.wifiName {
                textField.text = wifi
            }
        }
        
        let confirmAction = UIAlertAction(title: "OK", style: .default) { [weak alertController] _ in
            guard let alertController = alertController, let txtfd = alertController.textFields?.first  else { return }
            if let txt = txtfd.text , txt.count > 0 {
                self.geo.wifiName = txt
                self.lblWifi.text = self.geo.wifiName
            }
        }
        alertController.addAction(confirmAction)
        
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}



