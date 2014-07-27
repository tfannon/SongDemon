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
}

extension MPMediaItem {
    var songInfo: String {
        return "\(self.albumArtist) - \(self.albumTitle) : \(self.title)"
    }

    /* crashes compiler
    //provides a way to persist
    var hashKey: String {
        return self.persistentID.description;
    }
    */
}
