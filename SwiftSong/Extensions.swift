//
//  Extensions.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/10/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//
import MediaPlayer


extension String {
    var length: Int { return count(self) }  // Swift 1.2
}


extension MPMediaItem {
    var songInfo: String {
        return "\(self.albumArtist) - \(self.albumTitle) : \(self.albumTrackNumber). \(self.title)"
    }
    
    var year : String {
        var yearAsNum = self.valueForProperty("year") as! NSNumber
        if yearAsNum.isKindOfClass(NSNumber) {
            return yearAsNum == 0 ? "" : "\(yearAsNum.intValue)"
        }
        return ""
    }
    
    func getArtworkWithSize(frame : CGSize) -> UIImage? {
        return self.artwork != nil ? self.artwork.imageWithSize(frame) : nil
    }
    
    var playTime : TimeStruct {
        get {
            var totalPlaybackTime = Int(self.playbackDuration)
            let hours = (totalPlaybackTime / 3600)
            let mins = ((totalPlaybackTime/60) - hours*60)
            let secs = (totalPlaybackTime % 60 )
            return TimeStruct(hours: hours, mins: mins, seconds: secs)
        }
    }
    
    //provides a way to persist
    var hashKey: String {
        return self.persistentID.description;
    }
    
    var albumHashKey : String {
        return self.albumPersistentID.description;
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

extension Array {
    func find(includedElement: T -> Bool) -> Int? {
        for (idx, element) in enumerate(self) {
            if includedElement(element) {
                return idx
            }
        }
        return nil
    }
}
