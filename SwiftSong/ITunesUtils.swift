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
    
    class func getNewSongs() -> [MPMediaItem]? {
        var songs = [MPMediaItem]()
        var query = MPMediaQuery.songsQuery()
        var pred = MPMediaPropertyPredicate(value: "0", forProperty: MPMediaItemPropertyPlayCount, comparisonType: MPMediaPredicateComparison.EqualTo)
        
        query.addFilterPredicate(pred)
        for song : MPMediaItem in query.items as [MPMediaItem] {
            //println("\(song.albumArtist) - \(song.title)  plays:\(song.playCount)")
            songs.append(song)
        }
        println("0 play:  \(query.items.count)")
        query = MPMediaQuery.songsQuery()
        pred = MPMediaPropertyPredicate(value: "1", forProperty: MPMediaItemPropertyPlayCount, comparisonType: MPMediaPredicateComparison.EqualTo)
        for song : MPMediaItem in query.items as [MPMediaItem] {
            songs.append(song)
        }
        println("1 play:  \(query.items.count)")
        query = MPMediaQuery.songsQuery()
        pred = MPMediaPropertyPredicate(value: "2", forProperty: MPMediaItemPropertyPlayCount, comparisonType: MPMediaPredicateComparison.EqualTo)
        for song : MPMediaItem in query.items as [MPMediaItem] {
            songs.append(song)
        }
        println("2 plays:  \(query.items.count)")
        return songs
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

