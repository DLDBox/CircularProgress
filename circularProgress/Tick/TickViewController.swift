//
//  TickViewController.swift
//  circularProgress
//
//  Created by Dana Le Rhae De Voe on 8/6/19.
//  Copyright © 2019 Dana Le Rhae De Voe. All rights reserved.
//

import Foundation
import UIKit

class TickViewController: UIViewController {
    var circle: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let diameter = 200.0
        let ticks = 8
        
        circle = UIView(frame: CGRect(x: 0, y: 0, width: diameter, height: diameter))
        circle.center = view.center
        circle.backgroundColor = UIColor.yellow
        circle.layer.cornerRadius = 100.0
        view.addSubview(circle)
        
        drawTicks(count: ticks)
    }
    
    func drawTicks(count: Int) {
        
        let radius = circle.frame.size.width * 0.5
        var rotationInDegrees: CGFloat = 0
        
        for i in 0 ..< count {
            let tick = createTick()
            
            let x = CGFloat(Float(circle.center.x) + Float(radius) * cosf(2 * Float(i) * Float(Double.pi) / Float(count) - Float(Double.pi) / 2))
            let y = CGFloat(Float(circle.center.y) + Float(radius) * sinf(2 * Float(i) * Float(Double.pi) / Float(count) - Float(Double.pi) / 2))
            
            tick.center = CGPoint(x: x, y: y)
            // degress -> radians
            tick.transform = CGAffineTransform.identity.rotated(by: rotationInDegrees * .pi / 180.0)
            view.addSubview(tick)
            
            rotationInDegrees = rotationInDegrees + (360.0 / CGFloat(count))
        }
        
    }
    
    func createTick() -> UIView {
        let tick = UIView(frame: CGRect(x: 0, y: 0, width: 2.0, height: 10.0))
        tick.backgroundColor = UIColor.blue
        
        return tick
    }
}
