//
//  SetRadiusVC.swift
//  GeofencingSlate
//
//  Created by Rakhi on 02/02/19.
//  Copyright © 2019 myself. All rights reserved.
//

import UIKit
import CoreLocation

protocol SetRadiusDelegate: class {
    func setRadiusMonitring(_ radius: Int?)
}



class SetRadiusVC: UIViewController {
    
    var geoPass = GeoMod()
    weak var delegateRadCentre: SetRadiusDelegate?
    @IBOutlet weak var txfdRadius: UITextField!
    @IBOutlet weak var lblEnterRad: UILabel!
    
    
    // MARK: - VC LIFE CYCLE
    override func viewDidLoad() {
        super.viewDidLoad()
        initMethod()
        setUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        txfdRadius.becomeFirstResponder()
    }
    
    
    // MARK: - INIT METHOD
    private func initMethod() {
        title = "Add Radius"
    }
    
    // MARK: - SET UI
    private func setUI() {
        
        //lbl
        let loc = CLLocationManager()
        lblEnterRad.text = "Enter Monitoring Region Radius (max \(Int(loc.maximumRegionMonitoringDistance)) metres)"
        
        //txfd
        txfdRadius.layer.cornerRadius = 4
        txfdRadius.layer.borderColor = UIColor.gray.cgColor
        txfdRadius.layer.borderWidth = 1
        if let rad =  geoPass.geoRadius  {
            txfdRadius.text = String(rad)
        }
        addDoneButtonOnKeyboard()
    }
    
    
    
    func addDoneButtonOnKeyboard(){
        
        let toolBar = UIToolbar.init()
        toolBar.barStyle = UIBarStyle.default
        let done: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(self.doneButtonAction(_:)))
        toolBar.items = [done]
        done.tintColor = UIColor.orange
        toolBar.sizeToFit()
        txfdRadius.inputAccessoryView = toolBar
    }
    
    
    
    // MARK: - ACTION
    @objc func doneButtonAction(_ sender: UIBarButtonItem) {
        txfdRadius.resignFirstResponder()
    }
    
    
    @IBAction func btnSaveClicked(_ sender: UIBarButtonItem) {
        let loc = CLLocationManager()
        if let txt = txfdRadius.text , let rad = Int(txt) , rad > 0 && rad < Int(loc.maximumRegionMonitoringDistance) {
            delegateRadCentre?.setRadiusMonitring(rad)
            navigationController?.popViewController(animated: true)
        }else{
            Helper.getAlert(view: self, titletop: "Error", subtitle: "Please Enter Radius")
        }
    }
}



