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
    
    var description : String {
        if hours > 0 {
            return "\(hours):\(mins):\(seconds)"
        }
        return "\(mins):\(seconds)"
    }
}


extension String {
    var isEmpty : Bool {
        return self.utf16Count == 0
    }
}

  //crashes compiler
extension MPMediaItem {
    var songInfo: String {
        return "\(self.albumArtist) - \(self.albumTitle) : \(self.title)"
    }
    
    var playTime : TimeStruct {
        var totalPlaybackTime = Int(self.playbackDuration)
        //println(totalPlaybackTime)
        let hours = (totalPlaybackTime / 3600)
        let mins = ((totalPlaybackTime/60) - hours*60)
        let secs = (totalPlaybackTime % 60 )
        return TimeStruct(hours: hours, mins: mins, seconds: secs)
    }

  
    //provides a way to persist
    var hashKey: String {
        return self.persistentID.description;
    }
}


