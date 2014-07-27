//
//  Lyrics.swift
//  SwiftSong
//
//  Created by Tommy Fannon on 7/7/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import MediaPlayer

enum LyricState {
    case Available
    case Displayed
    case NotAvailable
}

class Lyrics {
    
    class func getUrlFor(item: MPMediaItem?) -> NSURL? {
        if Utils.inSimulator() {
            return NSURL.URLWithString("http://www.darklyrics.com/lyrics/goatwhore/carvingouttheeyesofgod.html#7")
        }
        if item != nil && item!.artist != nil && item!.albumArtist != nil {
            var artist = item!.albumArtist.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByReplacingOccurrencesOfString(" ", withString: "", options: .LiteralSearch, range: nil)
            var album = item!.albumTitle.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByReplacingOccurrencesOfString(" ", withString: "", options: .LiteralSearch, range: nil)
            var track = String(item!.albumTrackNumber)
            var urlStr = "http://www.darklyrics.com/lyrics/\(artist)/\(album).html#\(track)"
            println(urlStr)
            return NSURL.URLWithString(urlStr)
        } else {
            return nil
        }
    }
}
