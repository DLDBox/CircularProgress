//
//  CircularViewController.swift
//  circularProgress
//
//  Created by Dana Le Rhae De Voe on 8/22/19.
//  Copyright © 2019 Dana Le Rhae De Voe. All rights reserved.
//

import Foundation
import UIKit

class CircularViewController: UIViewController {
    
    @IBOutlet weak var circular: CircularView!
    
    override func viewDidAppear(_ animated: Bool) {
        self.circular?.startAnimation( completion: { self.dismiss(animated: true, completion: {}) } )
    }
}
