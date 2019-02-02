//
//  SettingVC.swift
//  GeofencingSlate
//
//  Created by Rakhi on 01/02/19.
//  Copyright © 2019 myself. All rights reserved.
//


import UIKit
import MapKit



class SettingVC: UITableViewController {
    
    var geo = GeoMod()
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblCentre: UILabel!
    @IBOutlet weak var lblRadius: UILabel!
    
    
    // MARK: - VC LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initMethod()
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
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
    
    
    // MARK: - SET UI
    private func setUI() {
    }
    
    
    private func sizeHeaderToFit() {
        
        let headerView = tableView.tableHeaderView!
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let height =  ScreenSize.SCREEN_HEIGHT - 5*50
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        tableView.tableHeaderView = headerView
    }
    
    
    
    
    
    // MARK: - TBLV DELEGATE
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let set = storyboard?.instantiateViewController(withIdentifier: "SetCentre") as! SetCentre
            set.delegateSetCentre = self
            navigationController?.pushViewController(set, animated: true)
        }else if indexPath.row == 1 {
            let set = storyboard?.instantiateViewController(withIdentifier: "SetRadiusVC") as! SetRadiusVC
            set.delegateRadCentre = self
            navigationController?.pushViewController(set, animated: true)
        }
    }
}



// MARK: - CUSTOM DELEGATES
extension SettingVC: SetCentreDelegate,SetRadiusDelegate {
    
    func setCentreMonitring(_ loc: CLLocationCoordinate2D?) {
        geo.geolat = loc?.latitude
        geo.geolon = loc?.longitude
        if let lat = geo.geolat,let lon = geo.geolon {
            lblCentre.text = "(\(lat),\(lon))"
            setAnnotationOnMap(CLLocationCoordinate2D.init(latitude: lat, longitude: lon))
        }
    }
    
    func setRadiusMonitring(_ radius: Int?){
        
        geo.geoRadius = radius
        
        //remove overlays
        if let overlays = mapView?.overlays {
            mapView.removeOverlays(overlays)
        }
        
        //add overlays
        let loc = CLLocationCoordinate2D.init(latitude: geo.geolat!, longitude: geo.geolon!)
        let mkCir = MKCircle.init(center: loc, radius: CLLocationDistance(geo.geoRadius!))
        mapView.addOverlay(mkCir)
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
        annotation.subtitle = "Monitoring region centre point"
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
        guard let circelOverLay = overlay as? MKCircle else {return MKOverlayRenderer()}
        
        
        let renderer = MKCircleRenderer(overlay: overlay)
        renderer.fillColor = UIColor.orange.withAlphaComponent(0.2)
        renderer.strokeColor = UIColor.orange
        renderer.lineWidth = 2
        return renderer
    }
}







