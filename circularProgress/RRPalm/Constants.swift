//
//  Defines.swift
//  GMI
//
//  Created by ddevoe on 1/17/19.

//

import Foundation

/* Use this file to hold the list of definitions that are used in the app.
 
 */

typealias Closure = () -> ()
typealias ClosureWithError = (Error?) -> ()
typealias ClosureWithBool = (Bool) -> ()
typealias ClosureWithInt = (Int) -> ()
typealias ClosureWithString = (String) -> ()
typealias ClosureWithStrings = ([String]) -> ()
typealias ClosureWithDict = ([String : Any]) -> ()
typealias ClosureWithModel = (Model) -> ()
typealias ClosureWithSystemAlert = (SystemAlert) ->()
//typealias ClosureWithDeviceDatum = (DeviceDatum) -> ()
typealias ClosureWithDeviceDatumStatus = (DeviceDatum?,Device.status) -> ()

typealias CHRONBOOL = Date? // A noval way to handle boolean values, nil == false, Date() == true

public struct K {
    
    public struct alert {
        static let storyboard = "Alerts"
        static let viewController = "StopEnrollmentAlert"
    }
    
    public struct notify { // any part of the app which want to know when a remote push notification has been received should subscribt
        // to this one using NotificationCenter.default.addObserver(self,selector:#selector(),name: K.notify.remote, object:nil)
        static let remote = NSNotification.Name("REMOTE_NOTIFY")
    }
}
