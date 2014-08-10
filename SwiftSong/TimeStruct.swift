//
//  TimeStruct.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/10/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

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

