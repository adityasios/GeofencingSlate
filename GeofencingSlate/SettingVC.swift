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
        setMapViewRegion()
    }
    

    private func setMapViewRegion() {
        
        let startCoord : CLLocationCoordinate2D = mapView.userLocation.coordinate
        print("startCoord (\(startCoord.latitude) \(startCoord.longitude))")
        
        var region = MKCoordinateRegion.init(center: startCoord, latitudinalMeters: 100, longitudinalMeters: 100)
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
        
        let height =  ScreenSize.SCREEN_HEIGHT - 6*50
        var frame = headerView.frame
        frame.size.height = height
        headerView.frame = frame
        tableView.tableHeaderView = headerView
    }
}




// MARK: - DELEGATES
extension SettingVC  {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            let set = storyboard?.instantiateViewController(withIdentifier: "SetCentre") as! SetCentre
            navigationController?.pushViewController(set, animated: true)
        }
    }
}







