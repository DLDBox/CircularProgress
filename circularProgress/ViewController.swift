//
//  ViewController.swift
//  circularProgress
//
//  Created by Dana Le Rhae De Voe on 7/29/19.
//  Copyright © 2019 Dana Le Rhae De Voe. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var circleProgress: CircularCountProgressView? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //self.circleProgress = CirclarCountProgressView(frame: self.view.bounds)
        self.circleProgress = CircularCountProgressView(frame: CGRect(x: 5.0, y: 0.0, width: 400, height: 600))
        self.view.addSubview(self.circleProgress!)
        
        self.view.backgroundColor = UIColor.darkGray
        
        view.addGestureRecognizer(UITapGestureRecognizer(target:self, action:#selector(handleTap)))
    }
    
    @objc private func handleTap() {
        self.circleProgress?.startAnimation( with: ["1","2","3","4","5","6","7"], completion: { print("!!!!!!!!!!!!!! DONE !!!!!!!!!!!!!!!!!" ) } )
    }
    
}

