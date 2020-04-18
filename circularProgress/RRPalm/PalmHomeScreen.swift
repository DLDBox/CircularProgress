//
//  PalmHomeScreen.swift
//  circularProgress
//
//  Created by Dana Le Rhae De Voe on 8/12/19.
//  Copyright © 2019 Dana Le Rhae De Voe. All rights reserved.
//

import Foundation
import UIKit
import RRBPalmSDK


class PalmHomeScreenViewController: UIViewController {
    
    @IBAction func didTouchScan(_ sender: Any) {
        
        let palmSettingViewController = RRBPalmSDKSettingsViewController()
        let navigationController = UINavigationController.init(rootViewController: palmSettingViewController)
        
        palmSettingViewController.completionHandler = { (error) in
            if error != nil {
                let alert = UIAlertController(title: "Registration failed", message: error?.localizedDescription, preferredStyle: .alert)
                alert.addAction(  UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(self, animated: true, completion: nil)
            }
        }
        
        self.present(navigationController, animated: true, completion: nil)
    }
    
}
