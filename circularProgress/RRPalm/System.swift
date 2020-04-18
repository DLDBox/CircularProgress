//
//  System.swift
//  GMI
//
//  Created by ddevoe on 5/23/19.
//  Copyright © 2019 Imageware Systems. All rights reserved.
//

import Foundation
import AVFoundation

class System {
    
    enum IWSError: Error{
        
        enum DeviceAccess {
            case undetermined
            case denied
            case granted
        }
        
        case access(IWSError.DeviceAccess)
        case user
        case outofmemory
        case filenotfound
        case imagecreation
        case startup
        case uknown
    }
    
    
    /* Returns an array classes which are direct children of the supplied class.
     
     This function can transverse 10 of thousands of classes so be careful using this function
     often in your code base.
    */
    static func subclasses<T>(of theClass: T) -> [T] {
        
        var count: UInt32 = 0, result: [T] = []
        let allClasses = objc_copyClassList(&count)!
        let classPtr = address(of: theClass)
        
        for n in 0 ..< count {
            let someClass: AnyClass = allClasses[Int(n)]
            guard let someSuperClass = class_getSuperclass(someClass), address(of: someSuperClass) == classPtr else { continue }
            result.append(someClass as! T)
        }
        
        return result
    }
    
    /* This function will return an array of all class which inherit from the given class at any point in it's
     inheritance tree.
     
     This function can transverse 10 of thousands of classes so be careful using this function
     often in your code base.
     */
    static func allsubclasses<T>(of theClass: T) -> [T] {
        
        var count: UInt32 = 0, result: [T] = []
        let allClasses = objc_copyClassList(&count)!
        let classPtr = address(of: theClass)
        
        defer {
            free(UnsafeMutableRawPointer(allClasses))
        }
        
        func ascendToRootParent( aClass: AnyClass) -> Bool {
            
            var someClass: AnyClass = aClass
            while let someSuperClass = class_getSuperclass(someClass) {
                
                if address(of: someSuperClass) == classPtr {
                    return true
                }
                someClass = someSuperClass
            }
            return false
        }
        
        for n in 0 ..< count {
            let someClass: AnyClass = allClasses[Int(n)]
            
            if ascendToRootParent( aClass: someClass ) {
                result.append(someClass as! T)
            }
        }
        
        return result
    }
    
    func withAllClasses<T>(_ body: (UnsafeBufferPointer<AnyClass>) throws -> T) rethrows -> T {
        
        var count: UInt32 = 0
        let classListPtr = objc_copyClassList(&count)
        
        defer {
            free(UnsafeMutableRawPointer(classListPtr))
        }
        
        let classListBuffer = UnsafeBufferPointer( start: classListPtr, count: Int(count) )
        
        return try body(classListBuffer)
    }

    // This function does not work on the iPhone 5, why is that.
    static func address(of object: Any?) -> UnsafeMutableRawPointer{
        return Unmanaged.passUnretained(object as AnyObject).toOpaque()
    }
    
    //
    //MARK:- Audio related
    //
    @discardableResult
    static func playBeep() -> Bool {
        let bundle = Bundle(for: SystemAlert.self)
        if let path = bundle.path(forResource: "beep", ofType: "wav") {
            
            let url = URL(fileURLWithPath: path)
            
            do {
                let beepSound = try AVAudioPlayer(contentsOf: url)
                beepSound.play()
            } catch {
                log.info( "Unable to play beep.wav" )
                return false
            }
            return true
        }
        log.info( "Unable to play beep.wav" )
        return false
    }
    
}
