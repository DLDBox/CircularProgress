//
//  Device.swift
//  GMI
//
//  Created by ddevoe on 1/17/19.

//

import Foundation
import UIKit

/* This file implements the device object.  A device object controls the collection of the raw data which
 is sent to the server as capture data, the device can be a camera, a microphone, a even a viewcontroller
 which access one of these devices.
 */

public protocol DeviceStatus {
}

extension DeviceStatus {
}

extension DeviceStatus where Self : RawRepresentable, Self.RawValue : FixedWidthInteger {
}

/* The device protocol definition */
protocol DeviceProtocol {
    
    var worker: ClosureWithDeviceDatumStatus? { get }
    var parameters: [String : Any]? { get}
    
    /*The name of the device such as Camera, Microphone, etc*/
    var name: String { get }
    
    /*Indicates if the current device is accessable*/
    var canAccess: Bool { get }
    
    /*System Alert for device access error*/
    var systemAlertID: SystemAlertDataSource { get }
    
    // MARK: - Live version
    /*Initialize the device with the appropriate view that it needs to imbed and execute*/
    func initDevice( with: UIView, params: [String : Any]?, completion:  @escaping ClosureWithBool )
    
    /*Request access to a device, the user will be presented with an alert to allow*/
    func requestAccess( completion: @escaping ClosureWithBool )
    
    /*Shuttown and clean up the device if needed*/
    func deInitDevice( completion: @escaping ClosureWithBool )
    
    /*Start the device capture process and returns with a dictionary when completed*/
    func startCapture( completion: @escaping ClosureWithDeviceDatumStatus )
    
    /*Stop the capture process for devices which require stopping*/
    func stopCapture( completion: @escaping ClosureWithDeviceDatumStatus )
    
    /*Reset the device back to the original state*/
    func restart()
    
}

/* This is the parent Device object.  Like all the parent objects all common device related functionality
 should be located here. */
class Device: NSObject, DeviceProtocol  {
    
    var view: UIView? = nil
    
    //
    //MARK: Constants
    //
    
    enum status: DeviceStatus {
        case startUp // not sure this will be reported, but might be useful
        case done // the device stopped with data
        case restart // go back to the startUp
        case nextStep // For capture process which require multiple steps such as getting the right and left palm scan, or first and second password
        case prevStep // For capture process which can back step such as face capture when face lock is lost
        case error // The device had a error
        case userError // an error caused by the user such as pin not matching,
        case timeout // for captures which have a time out such as face or voice, indicates that timeout expired
        case running // indicates the capture is still running in the background, stop() has to be called on the device
    }
    
    enum parameter { //use to pass data into the device
        case devicestatus(status) //??
        case data(DeviceDatum) //??
        case viewcontroller(UIViewController)
        case view(UIView)
        case syncdevice(Device)
        case iterationCount(Int)
        case misc(String, Any)
    }
    
    struct constant {
        
        static let STATUS = "DEVICE_STATUS"
        static let DATA = "DEVICE_DATA"
        
    }
    
    //
    //MARK: Private members
    //
    
    var _worker: ClosureWithDeviceDatumStatus? = nil
    var _parameters: [String : Any]? = nil
    
    var worker: ClosureWithDeviceDatumStatus? { get {return _worker} }
    var parameters: [String : Any]? { get {return _parameters} }
    
    //
    // MARK: Public members
    //
    
    var name: String { assert(false, "Function not implemented"); return "" }
    var canAccess: Bool { return false } // default behavoir, will cause the code to ask for permission if false is returned 
    var systemAlertID: SystemAlertDataSource { assert(false, "Function not implemented") ;return RD_Error() }
    
    func requestAccess( completion: @escaping ClosureWithBool ) {
        assert(false, "Function not implemented")
        completion(false)
    }
    
    func initDevice( with: UIView, params: [String : Any]?, completion: @escaping ClosureWithBool ) {
        self.view = with
        _parameters = params
    }
    
    func deInitDevice( completion:  @escaping ClosureWithBool ) {
        self.view?.removeFromSuperview()
        self.view = nil
        
        _worker = nil
        _parameters = nil
    }
    
    func startCapture( completion: @escaping  ClosureWithDeviceDatumStatus ) {
        _worker = completion
        //completion( .unknown,GMI.Device.status.error )
    }
    
    func stopCapture( completion:  @escaping ClosureWithDeviceDatumStatus ) {
        assert(false, "Function not implemented")
        completion( .unknown,Device.status.error )
    }
    
    func restart() {
        assert(false, "Reset not defined")
    }

}


