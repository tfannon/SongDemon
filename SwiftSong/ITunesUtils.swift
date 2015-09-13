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
        return query.items ;
    }
    
    class func getSongFrom(persistentId: String) -> MPMediaItem? {
        let query = MPMediaQuery.songsQuery()
        query.addFilterPredicate(MPMediaPropertyPredicate(value: persistentId, forProperty: MPMediaItemPropertyPersistentID))
        if query.items!.count > 0 {
            return (query.items as [MPMediaItem]!)[0]
        } else {
            return nil
        }
    }
    
    class func getSongsFrom(persistentIds: [String]) -> [MPMediaItem] {
        let songs = persistentIds.map { ITunesUtils.getSongFrom($0) }
        return songs.filter { $0 != nil }.map { $0! }
    }

    class func getArtists() -> [String] {
        var retval = [String]()
        let query = MPMediaQuery.artistsQuery()
        let artistsArray = query.collections
        for artistCollection in artistsArray! as [AnyObject] {
            let collection = artistCollection as! MPMediaItemCollection // artists[0] as MPMediaItemCollection
            let title  = collection.representativeItem!.valueForProperty(MPMediaItemPropertyAlbumArtist) as! String
            retval.append(title)
        }
        return retval
    }
    
    //playlist->songIds*
    class func getPlaylists(filter: [String] = []) -> [String: [String]] {
        var retVal = [String:[String]]()
        let query = MPMediaQuery.playlistsQuery()
        let playlists = query.collections
        for x in playlists! {
            let playlistTitle = x.valueForProperty(MPMediaPlaylistPropertyName) as! String
            var songIds = [String]()
            let songs = x.items as NSArray
            if filter.count == 0 || filter.indexOf(playlistTitle) != nil {
                for y in songs {
                    let id = y.valueForProperty(MPMediaItemPropertyPersistentID)!.description
                    songIds.append(id)
                }
                retVal[playlistTitle] = songIds
            }
        }
        return retVal
   }
}

