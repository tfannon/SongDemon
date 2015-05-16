//
//  Utils.swift
//  SwiftSong
//
//  Created by Tommy Fannon on 7/8/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit


class Utils {
    static var MIGRATED : String = "Migrated"

    class var inSimulator : Bool {
        get {
            let device = UIDevice.currentDevice().model
            return NSString(string:device).containsString("Simulator")
        }
    }
    
    static var AppGroupDefaults : NSUserDefaults = {
        let groupId = "group.com.crazy8dev.songdemon"
        let defaults = NSUserDefaults(suiteName: groupId)
        return defaults!
    }()
    
    func migrateDefaults() {
        if !Utils.AppGroupDefaults.boolForKey(Utils.MIGRATED) {
            var oldDefaults = NSUserDefaults.standardUserDefaults().dictionaryRepresentation() as! [String:AnyObject]
            for key in oldDefaults.keys {
                Utils.AppGroupDefaults.setObject(oldDefaults[key], forKey: key)
            }
            Utils.AppGroupDefaults.setBool(true, forKey: Utils.MIGRATED)
            Utils.AppGroupDefaults.synchronize()
        }
    }
    
    //generates random number between 0 and max-1
    class func random(max : Int) -> Int {
        return Int(arc4random_uniform((UInt32(max))))
    }
    /*
    class func shuffle<T>(var list: Array<T>) -> Array<T> {
        for i in 0..<list.count {
            let j = Int(arc4random_uniform(UInt32(list.count - i))) + i
            list.insert(list.removeAtIndex(j), atIndex: i)
        }
        return list
    }
    */
}

class Stopwatch {
    
    private var timer = NSDate()
    private var title : String = ""

    class func start() -> Stopwatch {
        return Stopwatch.start("")
    }
    
    class func start(title : String) -> Stopwatch {
        let sw = Stopwatch()
        sw.title = title
        if !title.isEmpty {
            println(title + " started")
        }
        sw.start()
        return sw
    }

    func start() {
        timer = NSDate()
    }
    
    func stop() -> Double {
        return stop("")
    }
    
    func stop(message : String) -> Double {
        let ret = NSDate().timeIntervalSinceDate(timer) * 1000
        if !title.isEmpty {
            println("\(title): \(message) completed in \(Int(ret))ms")
        }
        return ret
    }
    
    func takeTiming(message : String) -> Double {
        let ret = stop(message)
        start()
        return ret
    }
    
}






