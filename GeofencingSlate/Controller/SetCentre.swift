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
    func setCentreMonitring(_ loc: CLLocationCoordinate2D?)
}


class SetCentre: UIViewController {
    
    
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
        if let cord = mapView.userLocation.location {
            setMapViewRegion(loc: cord.coordinate)
            setAnnotationOnMap(loc: cord.coordinate)
        }
    }
    
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapSch(_:)))
        viewSch.addGestureRecognizer(tap)
        viewSch.isUserInteractionEnabled = true
    }
    
    
    private func setMapViewRegion(loc:CLLocationCoordinate2D) {
        print("Coord (\(loc.latitude) \(loc.longitude))")
        var region = MKCoordinateRegion.init(center: loc, latitudinalMeters: 100, longitudinalMeters: 100)
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
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
        let arrAnot = mapView.annotations.filter { $0 !== mapView.userLocation }
        if arrAnot.isEmpty {
            getAlert(titletop: "Error", subtitle: "Please Select Location")
        }else{
            delegateSetCentre?.setCentreMonitring(arrAnot.last?.coordinate)
            navigationController?.popViewController(animated: true)
        }
    }
}



// MARK: - SET PIN , MAP DELEGATES
extension SetCentre:MKMapViewDelegate  {
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
        annotation.subtitle = "Monitoring region centre point"
        mapView.addAnnotation(annotation)
    }
    
    
    func mapView(_ mapView: MKMapView,viewFor annotation: MKAnnotation) -> MKAnnotationView?{
        if annotation is MKPointAnnotation {
            let pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pincentre")
            pinAnnotationView.pinTintColor = .red
            pinAnnotationView.isDraggable = true
            pinAnnotationView.canShowCallout = true
            pinAnnotationView.animatesDrop = true
            return pinAnnotationView
        }
        
        return nil
        
    }
    
    
    func mapView(_ mapView: MKMapView,annotationView view: MKAnnotationView,didChange newState:MKAnnotationView.DragState,fromOldState oldState: MKAnnotationView.DragState){
        switch newState {
        case .starting:
            view.dragState = .dragging
        case .ending, .canceling:
            if let cord = view.annotation?.coordinate {
                setMapViewRegion(loc: cord)
            }
            view.dragState = .none
        default: break
        }
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
        print("place = \(place.coordinate.latitude) \(place.coordinate.longitude) \(place.formattedAddress!)")
        setAnnotationOnMap(loc: place.coordinate)
        setMapViewRegion(loc: place.coordinate)
        dismiss(animated: true, completion: nil)
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("error = \(error.localizedDescription)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("wasCancelled")
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - ALERT MANAGER
extension SetCentre  {

    func getAlert(titletop:String,subtitle:String){
        
        let AC = UIAlertController(title: titletop, message: subtitle, preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .cancel, handler: {(_ action: UIAlertAction) -> Void in
        })
        AC.addAction(okBtn)
        self.present(AC, animated: true, completion:nil)
    }
}

