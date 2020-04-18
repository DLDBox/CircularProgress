//
//  Circular.swift
//  circularProgress
//
//  Created by Dana Le Rhae De Voe on 8/22/19.
//  Copyright © 2019 Dana Le Rhae De Voe. All rights reserved.
//

import Foundation
import UIKit

class CircularView: CircularCountProgressView{
    
    override var strokeWidth: CGFloat { get {return 10.0} }
    override var marginWidth: CGFloat { get {return 10.0}}
    override var animationDuration: TimeInterval { get {return 8.0}}
    
    override var trackColor: CGColor { get {return UIColor.clear.cgColor} }
    override var progressColor: CGColor { get {return UIColor.red.cgColor} }
    override var fillColor: CGColor { get {return UIColor.clear.cgColor} }
    override var activeFillColor: CGColor { get {return UIColor.clear.cgColor}}
    override var textColor: CGColor { get {return UIColor.clear.cgColor} }
    
    override var tickCount: Int {get {return 0} }
    override var tickColor: UIColor { get {return UIColor.black}}
    override var tickWidth: CGFloat { get {return 2.0 }}

    
}
