//
//  Helper.swift
//  GeofencingSlate
//
//  Created by Rakhi on 30/01/19.
//  Copyright © 2019 myself. All rights reserved.
//

import Foundation
import UIKit

struct Helper {
    static let googleApiKey = "AIzaSyBV2FzDnZaAZHOzfoNL0YFmY6jTSW5_524"
    
    static  func getAlert(view:UIViewController,titletop:String,subtitle:String){
        let AC = UIAlertController(title: titletop, message: subtitle, preferredStyle: .alert)
        let okBtn = UIAlertAction(title: "OK", style: .default, handler: {(_ action: UIAlertAction) -> Void in
        })
        AC.addAction(okBtn)
        view.present(AC, animated: true, completion:nil)
    }
}


struct ScreenSize{
    static let SCREEN_WIDTH         = UIScreen.main.bounds.size.width
    static let SCREEN_HEIGHT        = UIScreen.main.bounds.size.height
    static let SCREEN_MAX_LENGTH    = max(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
    static let SCREEN_MIN_LENGTH    = min(ScreenSize.SCREEN_WIDTH, ScreenSize.SCREEN_HEIGHT)
}




