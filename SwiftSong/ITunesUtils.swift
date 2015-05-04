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
        return query.items as! [MPMediaItem]?;
    }
    
    class func getSongFrom(persistentId : String) -> MPMediaItem? {
        let query = MPMediaQuery.songsQuery()
        query.addFilterPredicate(MPMediaPropertyPredicate(value: persistentId, forProperty: MPMediaItemPropertyPersistentID))
        if query.items.count > 0 {
            return (query.items as! [MPMediaItem])[0]
        } else {
            return nil
        }
    }
    
    class func getSongFrom(persistentIds : [String]) -> [MPMediaItem] {
        let query = MPMediaQuery.songsQuery()
        query.addFilterPredicate(MPMediaPropertyPredicate(value: persistentIds, forProperty: MPMediaItemPropertyPersistentID))
        println (query.items)
        return query.items as! [MPMediaItem]
    }

    class func getArtists() -> [String] {
        var retval = [String]()
        let query = MPMediaQuery.artistsQuery()
        let artistsArray = query.collections
        for artistCollection in artistsArray as [AnyObject] {
            let collection = artistCollection as! MPMediaItemCollection // artists[0] as MPMediaItemCollection
            let title  = collection.representativeItem.valueForProperty(MPMediaItemPropertyAlbumArtist) as! String
            retval.append(title)
            //println(title)
        }
        return retval
    }
    
    //playlist->songIds*
    class func getPlaylists(filter : [String] = []) -> [String: [String]] {
        var retVal = [String:[String]]()
        var query = MPMediaQuery.playlistsQuery()
        var playlists = query.collections
        for x in playlists {
            let playlistTitle = x.valueForProperty(MPMediaPlaylistPropertyName) as! String
            var songIds = [String]()
            //println("Playlist: \(playlistTitle)")
            let songs = x.items as NSArray
            //println("songs")
            if filter.count == 0 || find(filter, playlistTitle) != nil {
                for y in songs {
                    let id = y.valueForProperty(MPMediaItemPropertyPersistentID).description
                    //let title = y.valueForProperty(MPMediaItemPropertyTitle) as String
                    //println("\(title) : \(id)")
                    songIds.append(id)
                }
                    
                retVal[playlistTitle] = songIds
            }
        }
        return retVal
   }
    
    class func getArtworkUrl(currentItem:MPMediaItem?) -> String {
        var artworkUrl = "https://www.google.com/url?sa=i&rct=j&q=&esrc=s&source=images&cd=&cad=rja&uact=8&docid=9Qlpc4H-2TLFtM&tbnid=CspfgTIw8O2WlM:&ved=0CAcQjRw&url=http%3A%2F%2Fwww.amazon.com%2FIn-Deathless-Tradition%2Fdp%2FB006TE2RYI&ei=MnsnVNv-HLLGsQSTloCwDg&bvm=bv.76247554,d.cWc&psig=AFQjCNEghidqWbYMWA6wruIkQTQo_iitnw&ust=1411959990101798"
        /*
        if currentItem != nil {
            var url = "http://itunes.apple.com/search?term=\(currentItem!.title)&country=us&media=music&entity=song\(currentItem.)&limit={2}";
            
        }
        */
        return artworkUrl
    }
}

