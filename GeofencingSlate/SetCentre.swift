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


class SetCentre: UIViewController {
    
    
    @IBOutlet weak var viewSch: UIView!
    
    // MARK: - VC LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add Centre"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUI()
    }
    
    
    
    // MARK: - INIT METHOD
    private func initMethod() {
        title = "Settings"
        addTapGesture()
    }
    
    
    private func addTapGesture() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.tapSch(_:)))
        viewSch.addGestureRecognizer(tap)
    }
    
    
    // MARK: - SET UI
    private func setUI() {
        viewSch.layer.cornerRadius = 4
        viewSch.layer.borderWidth = 1
        viewSch.layer.borderColor = UIColor.lightGray.cgColor
        viewSch.clipsToBounds = true
    }
    
    // MARK: - SETLECTOR METHOD
    @objc func tapSch(sender: UITapGestureRecognizer? = nil) {
        // handling code
    }
}




// MARK: - AUTOCOMPLETE
extension SetCentre : GMSAutocompleteViewControllerDelegate {
    
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
