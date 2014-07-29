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
        println("Indexed \(query.items.count) songs")
        return query.items as [MPMediaItem]?;
        
        /*
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
        
        
        return nil
        */
    }
    
    class func getLikedSongs() -> [MPMediaItem]? {
        var query = MPMediaQuery.songsQuery()
        //query.groupingType = MPMediaGrouping.
        var pred = MPMediaPropertyPredicate(value: "2", forProperty: MPMediaItemPropertyRating, comparisonType: MPMediaPredicateComparison.EqualTo)
        query.addFilterPredicate(pred)
        for song : MPMediaItem in query.items as [MPMediaItem] {
            println("\(song.albumArtist) - \(song.title)")
        }
        return nil
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

