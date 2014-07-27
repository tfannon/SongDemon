//
//  ITunesUtils.swift
//  SwiftSong
//
//  Created by Tommy Fannon on 6/19/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//
import MediaPlayer

class ITunesUtils {

    class func getAllSongs() -> Array<MPMediaItem>? {
        let query = MPMediaQuery.songsQuery()
        if query.items.count == 0 {
            return nil }
        let coll = MPMediaItemCollection(items: query.items)
        var songdict = Dictionary<Int64, MPMediaItem>()
        for i : AnyObject in coll.items {
            var item = i as MPMediaItem
            if (item.albumArtist) {
                //println(item.albumArtist + " - " + item.title)
                songdict[item.persistentID.asSigned()] = item
                    //println(\(item.persistentID) + " - " + item.albumArtist + " - " + item.title)
                }
        }
        println("Indexed \(coll.items.count) items")
        
        return nil
    }
}
