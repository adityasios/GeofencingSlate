//
//  SettingVC.swift
//  GeofencingSlate
//
//  Created by Rakhi on 01/02/19.
//  Copyright © 2019 myself. All rights reserved.
//


import UIKit
import MapKit
import GooglePlaces
import GoogleMaps

class SettingVC: UITableViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblCentre: UILabel!
    @IBOutlet weak var lblRadius: UILabel!
    
    // MARK: - VC LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initMethod()
    }
    
    private func initMethod() {
        setMapViewRegion()
    }
    
    
    private func setMapViewRegion() {
        
        let startCoord : CLLocationCoordinate2D = mapView.userLocation.coordinate
        print("startCoord (\(startCoord.latitude) \(startCoord.longitude))")
        
        var region = MKCoordinateRegion.init(center: startCoord, latitudinalMeters: 100, longitudinalMeters: 100)
        region = mapView.regionThatFits(region)
        mapView.setRegion(region, animated: true)
    }
}

// MARK: - DELEGATES
extension SettingVC  {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            showAutoComplete()
        }
    }
}


// MARK: - AUTOCOMPLETE
extension SettingVC : GMSAutocompleteViewControllerDelegate {
    
    func showAutoComplete() {
        let autocompleteController = GMSAutocompleteViewController()
        autocompleteController.delegate = self
        navigationController?.pushViewController(autocompleteController, animated: false)
        
    }
    
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        print("place = \(place.coordinate.latitude) \(place.coordinate.longitude) \(place.formattedAddress!)")
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("error = \(error.localizedDescription)")
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        print("wasCancelled")
        navigationController?.popViewController(animated: false)
    }
}

