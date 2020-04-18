//
//  CircleCountProgressView.swift
//  circularProgress
//
//  Created by Dana Le Rhae De Voe on 7/29/19.
//  Copyright © 2019 Dana Le Rhae De Voe. All rights reserved.
//

import Foundation
import UIKit

/* This class implementes the circlar progress with the center digit display
 */
class CircularCountProgressView: UIView {
    
    struct K {
        static var tickID = 783482
    }
    
    //
    //MARK:- Private sesssion
    //
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    var textLayer = CATextLayer()
    var countFired = 0
    
    //
    //MARK:- Public overrideable section
    //
    var strokeWidth: CGFloat { get {return 30.0} }
    var marginWidth: CGFloat { get {return 10.0}}
    var animationDuration: TimeInterval { get {return 8.0}}
    
    var trackColor: CGColor { get {return UIColor.lightGray.cgColor} }
    var progressColor: CGColor { get {return UIColor.green.cgColor} }
    var fillColor: CGColor { get {return UIColor.gray.cgColor} }
    var activeFillColor: CGColor { get {return UIColor.blue.cgColor}}
    var textColor: CGColor { get {return UIColor.white.cgColor} }
    
    var tickCount: Int {get {return 8} }
    var tickColor: UIColor { get {return UIColor.black}}
    var tickWidth: CGFloat { get {return 2.0 }}
    
    public var progress: CGFloat = 0 {
        didSet {
            didProgressUpdated()
        }
    }
    
    override func draw(_ rect: CGRect) {
        
        // I must have a square for the code to draw correctly
        assert( self.bounds.size.width == self.bounds.size.height )
        
        // let draw a circle
        let center = CGPoint(x: self.center.x - self.frame.origin.x, y: self.center.y - self.frame.origin.y)
        let radius = min(self.bounds.size.width, self.bounds.size.height)
        let circlarPath = UIBezierPath(arcCenter: center, radius: (radius - center.x) - self.strokeWidth,
                                       startAngle: -1 * CGFloat.pi / 2, endAngle: 2 * CGFloat.pi, clockwise: true)
        
        trackLayer.path = circlarPath.cgPath
        trackLayer.strokeColor = self.trackColor
        trackLayer.lineWidth = self.strokeWidth
        trackLayer.fillColor = self.fillColor
        trackLayer.lineCap = CAShapeLayerLineCap.round
        trackLayer.strokeEnd = 1
        self.layer.addSublayer(trackLayer)
        
        // The animated shape
        shapeLayer.path = circlarPath.cgPath
        shapeLayer.strokeColor = self.progressColor
        shapeLayer.lineWidth = self.strokeWidth
        shapeLayer.strokeEnd = 0
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineCap = CAShapeLayerLineCap.round
        self.layer.addSublayer(shapeLayer)
        
        self.textLayer = self.createTextLayer(rect: rect, textColor: self.textColor)
        self.layer.addSublayer(self.textLayer)
        
        self.textLayer.string = ""
        
        self.drawTicks(count: self.tickCount)
    }
    
    static func Ticker( progressView: CircularCountProgressView, count: Int ) {
        progressView.drawTicks(count: count)
    }
    
    // Start animation with a random center digits displayed, chosen from a list
    func startAnimation( with digits: [String], completion: @escaping ()->() ) {
        
        self.countFired = 0
        DispatchQueue.main.async {
            
           self.trackLayer.fillColor = self.activeFillColor
            
            let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            basicAnimation.toValue = 1 // take teh animation to the end point
            basicAnimation.duration = self.animationDuration // in seconds
            
            // persists the drawing on the border
            basicAnimation.fillMode = CAMediaTimingFillMode.forwards
            basicAnimation.isRemovedOnCompletion = false
            
            self.shapeLayer.add(basicAnimation, forKey: "circularProgress")
            
            self.textLayer.string = digits[self.countFired]
            
            Timer.scheduledTimer(withTimeInterval: self.animationDuration / TimeInterval(digits.count+1), repeats: true) { (timer) in
                self.countFired += 1
                
                if self.countFired < digits.count {
                    self.textLayer.string = digits[self.countFired]
                } else {
                    self.trackLayer.fillColor = self.fillColor
                    timer.invalidate()
                    completion()
                }
            }
        }
    }
    
    // Start animation without a center digit displayed
    func startAnimation( completion: @escaping () -> () ) {
        
        DispatchQueue.main.async {
            
            self.trackLayer.fillColor = self.activeFillColor
            
            let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
            basicAnimation.toValue = 1 // take teh animation to the end point
            basicAnimation.duration = self.animationDuration // in seconds
            
            // persists the drawing on the border
            basicAnimation.fillMode = CAMediaTimingFillMode.forwards
            basicAnimation.isRemovedOnCompletion = false
            
            self.shapeLayer.add(basicAnimation, forKey: "circularProgress")
            
            Timer.scheduledTimer(withTimeInterval: self.animationDuration, repeats: true) { (timer) in
                self.trackLayer.fillColor = self.fillColor
                timer.invalidate()
                completion()
            }
        }
    }
    
    //
    //MARk:- Private section
    //
    private func createTextLayer(rect: CGRect, textColor: CGColor) -> CATextLayer {
        
        let width = rect.width
        let height = rect.height
        
        let fontSize = min(width, height) / 4
        let offset = min(width, height) * 0.1
        
        let layer = CATextLayer()
        layer.backgroundColor = UIColor.clear.cgColor
        layer.foregroundColor = textColor
        layer.fontSize = fontSize
        layer.frame = CGRect(x: 0, y: (height - fontSize - offset) / 2, width: width, height: fontSize + offset)
        layer.alignmentMode = .center
        
        return layer
    }
    
    private func didProgressUpdated() {
        shapeLayer.strokeEnd = progress
    }
    
    func drawTicks(count: Int) {
        
        let center = CGPoint(x: self.center.x - self.frame.origin.x, y: self.center.y - self.frame.origin.y)
        let radius = min(self.bounds.size.width, self.bounds.size.height) - (center.x + self.strokeWidth)
        
        var rotationInDegrees: CGFloat = 0
        
        for _ in 0 ..< count { // remove all current tick views that are already in the view
            if let view = self.viewWithTag(K.tickID) {
                view.removeFromSuperview()
            } else {
                break
            }
        }

        // Redraw the ticks
        for i in 0 ..< count {
            let tick = createTick()
            
            let x = CGFloat(Float(center.x) + Float(radius) * cosf(2 * Float(i) * Float(Double.pi) / Float(count) - Float(Double.pi) / 2))
            let y = CGFloat(Float(center.y) + Float(radius) * sinf(2 * Float(i) * Float(Double.pi) / Float(count) - Float(Double.pi) / 2))
            
            tick.center = CGPoint(x: x, y: y)
            // degress -> radians; draw a tick rotated  along the circle
            tick.transform = CGAffineTransform.identity.rotated(by: rotationInDegrees * .pi / 180.0)
            self.addSubview(tick)
            
            rotationInDegrees = rotationInDegrees + (360.0 / CGFloat(count)) // calculate the new angle for the next tick
        }
        
    }
    
    // Create a tick as a view
    func createTick() -> UIView {
        let tick = UIView(frame: CGRect(x: 0, y: 0, width: self.tickWidth, height: self.strokeWidth ))
        tick.backgroundColor = self.tickColor
        tick.tag = K.tickID
        
        return tick
    }
    
}
