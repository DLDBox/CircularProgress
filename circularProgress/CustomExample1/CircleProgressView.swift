//
//  CircleProgressView.swift
//  circularProgress
//
//  Created by Dana Le Rhae De Voe on 8/7/19.
//  Copyright © 2019 Dana Le Rhae De Voe. All rights reserved.
//

import Foundation
import UIKit

class CircleProgressViewController: UIViewController {
    
    @IBOutlet weak var circleProgress: CirclarCountProgressView!
    
    override func viewDidAppear(_ animated: Bool) {
        self.circleProgress?.startAnimation( with: ["0","1","2","3","4","5","6"], completion: {  self.dismiss(animated: true, completion: {})  } )
    }
}
