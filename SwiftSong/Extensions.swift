//
//  Extensions.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/10/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//
import MediaPlayer


extension String {
    var isEmpty : Bool {
        return self.utf16Count == 0
    }
}


extension MPMediaItem {
    var songInfo: String {
        return "\(self.albumArtist) - \(self.albumTitle) : \(self.albumTrackNumber). \(self.title)"
    }
    
    var year : String {
        var yearAsNum = self.valueForProperty("year") as NSNumber
        if yearAsNum != nil && yearAsNum.isKindOfClass(NSNumber) && yearAsNum > 0 {
            return "\(yearAsNum.intValue)"
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
