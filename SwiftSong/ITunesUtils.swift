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
        return query.items as [MPMediaItem]?;
    }
    
    class func getSongFrom(persistentId : String) -> MPMediaItem? {
        let query = MPMediaQuery.songsQuery()
        query.addFilterPredicate(MPMediaPropertyPredicate(value: persistentId, forProperty: MPMediaItemPropertyPersistentID))
        if query.items.count > 0 {
            return (query.items as [MPMediaItem])[0]
        } else {
            return nil
        }
    }
}

