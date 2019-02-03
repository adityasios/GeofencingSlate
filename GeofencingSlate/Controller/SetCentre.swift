//
//  SetCentre.swift
//  GeofencingSlate
//
//  Created by Rakhi on 02/02/19.
//  Copyright © 2019 myself. All rights reserved.
//

import UIKit
import GooglePlaces
import GoogleMaps
import MapKit




protocol SetCentreDelegate: class {
    func setCentreMonitring(_ geod: GeoMod)
}


class SetCentre: UIViewController {
    
    var geoPass = GeoMod()
    
    weak var delegateSetCentre: SetCentreDelegate?
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viewSch: UIView!
    
    
    
    // MARK: - VC LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initMethod()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    
    // MARK: - INIT METHOD
    private func initMethod() {
        title = "Add Centre"
        addTapGesture()
        
        if geoPass.geolat != nil && geoPass.geolon != nil {
            let loc = CLLocationCoordinate2D.init(latitude: geoPass.geolat!, longitude: geoPass.geolat!)
            setMapViewRegion(loc: loc)
            setAnnotationOnMap(loc: loc)
        }else if let cord = mapView.userLocation.location {
            setMapViewRegion(loc: cord.coordinate)
        }
    }
    
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapSch(_:)))
        viewSch.addGestureRecognizer(tap)
        viewSch.isUserInteractionEnabled = true
    }
    
    
    
    
    
    
    // MARK: - SET UI
    private func setUI() {
        viewSch.layer.cornerRadius = 4
        viewSch.layer.borderWidth = 1
        viewSch.layer.borderColor = UIColor.lightGray.cgColor
        viewSch.clipsToBounds = true
    }
    
    
    
    // MARK: - SETLECTOR METHOD
    @objc func tapSch(_ sender: UITapGestureRecognizer) {
        showAutoComplete()
    }
    
    @IBAction func btnSaveClicked(_ sender: UIBarButtonItem) {
        if geoPass.geolat != nil && geoPass.geolon != nil  && geoPass.geoAdd != nil{
            delegateSetCentre?.setCentreMonitring(geoPass)
            navigationController?.popViewController(animated: true)
        }else{
            Helper.getAlert(view: self, titletop: "Error", subtitle: "Please Select Location")
        }
    }
}



// MARK: - MAP METHODS , MAP DELEGATES
extension SetCentre:MKMapViewDelegate  {
    
    private func setMapViewRegion(loc:CLLocationCoordinate2D) {
        var region = MKCoordinateRegion.init(center: loc, latitudinalMeters: 100, longitudinalMeters: 100)
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
    
    
    
    private func setAnnotationOnMap(loc:CLLocationCoordinate2D) {
        
        //remove pre
        let arrAnot = mapView.annotations.filter { $0 !== mapView.userLocation }
        if !arrAnot.isEmpty {
            mapView.removeAnnotations( arrAnot )
        }
        
        //add new
        let annotation = MKPointAnnotation()
        annotation.coordinate = loc
        annotation.title = "Centre"
        annotation.subtitle = geoPass.geoAdd ?? "Monitoring region centre point"
        mapView.addAnnotation(annotation)
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




// MARK: - AUTOCOMPLETE
extension SetCentre : GMSAutocompleteViewControllerDelegate {
    
    func showAutoComplete() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        navigationController?.present(autocompleteController, animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        
        //save data
        geoPass.geolat = place.coordinate.latitude
        geoPass.geolon = place.coordinate.longitude
        geoPass.geoAdd = place.formattedAddress ?? "Monitoring region centre point"
        
        
        //set map
        setAnnotationOnMap(loc: place.coordinate)
        setMapViewRegion(loc: place.coordinate)
        dismiss(animated: true, completion: nil)
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("error = \(error.localizedDescription)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        dismiss(animated: true, completion: nil)
    }
}




