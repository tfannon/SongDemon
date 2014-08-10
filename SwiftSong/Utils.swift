//
//  Utils.swift
//  SwiftSong
//
//  Created by Tommy Fannon on 7/8/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit


class Utils {
    class var inSimulator : Bool {
        get {
            let device = UIDevice.currentDevice().model
            return NSString(string:device).containsString("Simulator")
        }
    }
    
    class func random(max : Int) -> Int {
        return Int(arc4random_uniform((UInt32(max))))
    }
    
    class func shuffle<T>(var list: Array<T>) -> Array<T> {
        for i in 0..<list.count {
            let j = Int(arc4random_uniform(UInt32(list.count - i))) + i
            list.insert(list.removeAtIndex(j), atIndex: i)
        }
        return list
    }
}






