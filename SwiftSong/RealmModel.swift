//
//  Model.swift
//  SongDemon
//
//  Created by Tommy Fannon on 2/28/16.
//  Copyright © 2016 crazy8dev. All rights reserved.
//

import RealmSwift
import MediaPlayer

class RealmSong: Object {
    dynamic var id = ""
    dynamic var title = ""
    dynamic var artist = ""
    dynamic var album = ""

    override static func primaryKey() -> String? {
        return "id"
    }
}

class RealmPlaylist: Object {
    dynamic var name = ""
    let songs = List<RealmSong>()
    
    override static func primaryKey() -> String? {
        return "name"
    }
}

class RealmHelper {

    static func toRealmObject(item: MPMediaItem) -> RealmSong? {
        //MPMediaItem must have some properties set to work
        if  let title = item.title,
            let artist = item.albumArtist,
            let album = item.albumTitle {

                let song = RealmSong()
                song.id = item.hashKey
                song.title = title
                song.artist = artist
                song.album = album
                return song
        }
        return nil
    }
    
    static func serializeCurrentPlaylist() {
        let current = RealmPlaylist()
        current.name = CURRENT_LIST
        let songs = LibraryManager.currentPlaylist
            .flatMap { RealmHelper.toRealmObject($0) }
        current.songs.appendContentsOf(songs)
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
            realm.add(current, update: true)
        }
    }
    
//    static func restoreCurrentPlaylist() {
//        let realm = try! Realm()
//        if let playlist = realm.objectForPrimaryKey(RealmPlaylist.self, key: CURRENT_LIST) {
//            for song in playlist.songs {
//                let predicate = MPMediaPropertyPredicate(value: song.id, forProperty: MPMediaItemPropertyPersistentID)
//                let query = MPMediaQuery(filterPredicates: Set(arrayLiteral: predicate))
//                //            for x in query.items! {
//                //                print (x)
//                //            }
//            
//        }
//    }
    
}
