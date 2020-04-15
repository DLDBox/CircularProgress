//
//  CustomExample3.swift
//  circularProgress
//
//  Created by Dana Devoe on 4/9/20.
//  Copyright © 2020 Dana Le Rhae De Voe. All rights reserved.
//

import Foundation
import UIKit

/* Create a custome Circular progress View.
 */
class CustomExample3: CirclarCountProgressView {
    
    override var strokeWidth: CGFloat { get {return 20.0} }
    override var marginWidth: CGFloat { get {return 10.0}}
    override var animationDuration: TimeInterval { get {return 10.0}}
    
    override var trackColor: CGColor { get {return UIColor.gray.cgColor} }
    override var progressColor: CGColor { get {return UIColor.black.cgColor} }
    override var fillColor: CGColor { get {return UIColor.blue.cgColor} }
    override var activeFillColor: CGColor { get {return UIColor.green.cgColor}}
    override var textColor: CGColor { get {return UIColor.white.cgColor} }
    
    override var tickCount: Int {get {return 4} }
    override var tickColor: UIColor { get {return UIColor.white}}
    override var tickWidth: CGFloat { get {return 10.0 }}
    
}

class CustomExample3ViewController: UIViewController {
    
    @IBOutlet weak var circular: CustomExample3!
        
    override func viewDidAppear(_ animated: Bool) {
        self.circular?.startAnimation( with: ["1","2","3","4","5","6","7"], completion: {  self.dismiss(animated: true, completion: {})  } )
        //self.circular?.startAnimation( completion: { self.dismiss(animated: true, completion: {}) } )
    }
    
}
