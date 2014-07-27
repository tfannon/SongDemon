//
//  LibraryManager.swift
//  SwiftSong
//
//  Created by Tommy Fannon on 6/19/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//
import MediaPlayer

let LIKED_LIST = "Liked"
let DISLIKED_LIST = "Disliked"
let gLibraryManager = LibraryManager()

class LibraryManager {
    
    final var LikedSongs = Dictionary<String, String>()
    final var DislikedSongs = Dictionary<String, String>()
    

    init() {
        println("storage objects being initialized from NSDefaults")
        let userDefaults = NSUserDefaults.standardUserDefaults();
        if let result = userDefaults.objectForKey(LIKED_LIST) as? Dictionary<String,String> {
            //println("all liked songs: \(result)")
            //construct the liked songs from the defaults
            for (x,y) in result {
               LikedSongs[x] = y
               println("\(x):\(y)")
            }
        }
        if let result = userDefaults.objectForKey(DISLIKED_LIST) as? Dictionary<String,String> {
            println("all disliked songs: \(result)")
            //construct the disliked songs from the defaults
            for (x,y) in result {
                DislikedSongs[x] = y
            }
        }
    }

    func addToLiked(item:MPMediaItem) {
        addToList(LIKED_LIST, list: &LikedSongs, item: item)
    }
    
    func removeFromLiked(item:MPMediaItem) {
        removeFromList(LIKED_LIST, list: &LikedSongs, item: item)
    }
    
    func addToDisliked(item:MPMediaItem) {
        addToList(DISLIKED_LIST, list: &DislikedSongs, item: item)
        //adding it to disliked will remove it from liked
        removeFromLiked(item)
    }
    
    private func addToList(listName:String, inout list:Dictionary<String,String>, item:MPMediaItem) {
        if (item != nil) {
            list[getHashKey(item)] = item.title
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(list, forKey: listName)
            //println(item.songInfo)
             //dumpNSUserDefaults(LIKED_LIST)
        }
    }
    
    private func removeFromList(listName:String, inout list:Dictionary<String,String>, item:MPMediaItem) {
        if (item != nil) {
            list.removeValueForKey(getHashKey(item));
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(list, forKey: listName)
        }
    }
    
    private func getHashKey(item:MPMediaItem) -> String {
        return item.persistentID.description
    }

    func addToPlaylist(items:[MPMediaItem]) -> Void {
        for item in items {
           LikedSongs[getHashKey(item)] = item.title
        }
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(LikedSongs, forKey: LIKED_LIST)
        println ("added \(items.count) songs")
        //dumpNSUserDefaults(LIKED_LIST)
    }
    
    func isLiked(item:MPMediaItem) -> Bool {
        if item != nil {
            if let oldSong = LikedSongs[getHashKey(item)] {
                return true;
            }
        }
        return false;
    }
    
    func dumpNSUserDefaults(forKey:String) -> Void {
        println("Current dictionary: \(self.LikedSongs)")
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let songsFromDefaults = userDefaults.objectForKey(forKey) as? Dictionary<String,String> {
            println("Current defaults: \(songsFromDefaults)")
        } else {
            println("No userDefaults")
        }
    }
}
