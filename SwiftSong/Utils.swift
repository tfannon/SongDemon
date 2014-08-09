//
//  Utils.swift
//  SwiftSong
//
//  Created by Tommy Fannon on 7/8/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import MediaPlayer

class Utils {
    class func inSimulator() -> Bool {
        let device = UIDevice.currentDevice().model
        return NSString(string:device).containsString("Simulator")
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

/*
extension Array {
    func shuffle<T>(var list: Array<T>) -> Array<T> {
        for i in 0..<list.count {
            let j = Int(arc4random_uniform(UInt32(list.count - i))) + i
            list.insert(list.removeAtIndex(j), atIndex: i)
        }
        return list
    }
}
*/

class TimeStruct : Printable {
    var hours : Int
    var mins : Int
    var seconds : Int
    
    init(hours:Int, mins:Int, seconds:Int) {
        self.hours = hours
        self.mins = mins
        self.seconds = seconds
    }
    
    init(totalSeconds:Float) {
        var rem = Int(totalSeconds)
        hours = rem / 3600
        mins = ((rem / 60) - hours*60)
        seconds = rem % 60
        println("Timestruct created \(self) from float:\(totalSeconds) seconds")
    }
    
    init(totalSeconds:Int) {
        var rem = totalSeconds
        hours = rem / 3600
        mins = ((rem / 60) - hours*60)
        seconds = rem % 60
        println("Timestruct created \(self) from int:\(totalSeconds) seconds")
    }
    
    var description : String {
        if hours > 0 {
            return "\(hours):\(mins):\(seconds)"
        }
        return "\(mins):\(seconds)"
    }
    
    var totalSeconds : Int {
        return hours * 3600 + mins * 60 + seconds
    }
}


extension String {
    var isEmpty : Bool {
        return self.utf16Count == 0
    }
}


extension MPMediaItem {
    var songInfo: String {
        return "\(self.albumArtist) - \(self.albumTitle) : \(self.title)"
    }
    
    
    var playTime : TimeStruct {
        get {
            var totalPlaybackTime = Int(self.playbackDuration)
            let hours = (totalPlaybackTime / 3600)
            let mins = ((totalPlaybackTime/60) - hours*60)
            let secs = (totalPlaybackTime % 60 )
            return TimeStruct(hours: hours, mins: mins, seconds: secs)
        }
        /*
        set(time) {
            //self.set
        }
        */
    }

  
    //provides a way to persist
    var hashKey: String {
        return self.persistentID.description;
    }
}

extension UISlider {
    var timeValue : TimeStruct {
        get {
            return TimeStruct(totalSeconds: self.value)
        }
        set(time) {
            self.value = Float(time.totalSeconds)
        }
    }
}

