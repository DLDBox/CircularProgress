//
//  CaptureFlowData.swift
//  GMI
//
//  Created by ddevoe on 5/20/19.
//  Copyright © 2019 Imageware Systems. All rights reserved.
//

import Foundation
import UIKit

/*This object holds the data from a capture response process.
  Stores the data elements for each of the different captureTypes*/
public enum DeviceDatum {
    
    case data(Data,String) //generic data, meme
    case error(Error)
    case face(Data,String,Date?) // UIImage(Data), memetype, live<optional> if nil then NA
    case facevoice(Data,[Data],String,Date?) // UIImage(Data), WAV(Data), memetype, liveness
    case palm(Data,String) // UIImage(Data), memetype,
    case palmPosition(CGPoint,CGPoint,CGPoint,CGPoint)
    case pin(String) // pin string
    case voice([Data],String) // WAV(Data), memtype
    case yesno(Bool)
    case unknown // all else
    //case localStatus(Int)
    
}

//typealias DeviceDatum = CaptureResponseDatum
