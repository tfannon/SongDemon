
import MediaPlayer

let LIKED_LIST = "Liked"
let DISLIKED_LIST = "Disliked"
private let LM = LibraryManager()

class LibraryManager {
    //the finals are to get around a performance bug where adding items to a dictionary is very slow
    private final var LikedSongs = Dictionary<String, String>()
    private final var DislikedSongs = Dictionary<String, String>()
    //computed at load
    private final var RatedSongs = Array<String>()
    private final var LowRatedSongs = Array<String>()
    private final var NotPlayedSongs = Array<String>()
    private var scanned = false
    //playlist 
    private final var Playlist = Array<MPMediaItem>()

    init() {
        println("storage objects being initialized from NSDefaults")
        let userDefaults = NSUserDefaults.standardUserDefaults();
        if let result = userDefaults.objectForKey(LIKED_LIST) as? Dictionary<String,String> {
            //println("all liked songs: \(result)")
            //construct the liked songs from the defaults
            for (x,y) in result {
               LikedSongs[x] = y
               //println("\(x):\(y)")
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
    
    class func scanLibrary() {
        if LM.scanned { return };
        var unplayed = 0;
        var start = NSDate()
        if let allSongs = ITunesUtils.getAllSongs() {
            for song in allSongs {
                //an album must have an album artist and title and a rating to make the cut
                if song.albumArtist != nil && song.title != nil {
                    if song.rating >= 1 {
                        //var info = SongInfo(id: song.persistentID.description, rating:song.rating, playCount:song.playCount)
                        switch (song.rating) {
                        case 0:""
                        case 1:
                            LM.LowRatedSongs.append(getHashKey(song))
                            //println("Low: \(song.title)")
                        default:
                            LM.RatedSongs.append(getHashKey(song))
                            //println("High: \(song.title)")
                        }
                    }
                    else if song.playCount == 0 || song.playCount == 1 {
                        LM.NotPlayedSongs.append(getHashKey(song))
                        unplayed++
                    }
                }
            }
            println("Indexed \(allSongs.count) songs")
        }
        let time = NSDate().timeIntervalSinceDate(start) * 1000
        println("Scanned iTunes in \(time)ms. \n  \(LM.RatedSongs.count) songs with >1 rating \n  \(LM.LowRatedSongs.count) songs with =1 rating \n  \(unplayed) songs with playcount of 0 or 1")
        LM.scanned = true;
    }

    class func addToLiked(item:MPMediaItem) {
        addToList(LIKED_LIST, list: &LM.LikedSongs, item: item)
    }
    
    class func removeFromLiked(item:MPMediaItem) {
        removeFromList(LIKED_LIST, list: &LM.LikedSongs, item: item)
    }
    
    class func addToDisliked(item:MPMediaItem) {
        addToList(DISLIKED_LIST, list: &LM.DislikedSongs, item: item)
        //adding it to disliked will remove it from liked
        removeFromLiked(item)
    }
    
    private class func addToList(listName:String, inout list:Dictionary<String,String>, item:MPMediaItem) {
        if (item != nil) {
            list[getHashKey(item)] = item.title
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(list, forKey: listName)
            //println(item.songInfo)
             //dumpNSUserDefaults(LIKED_LIST)
        }
    }
    
    private class func removeFromList(listName:String, inout list:Dictionary<String,String>, item:MPMediaItem) {
        if (item != nil) {
            list.removeValueForKey(getHashKey(item));
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(list, forKey: listName)
        }
    }
    
    private class func getHashKey(item:MPMediaItem) -> String {
        return item.persistentID.description
    }
    
    class func getSongInfo(item:MPMediaItem) -> String {
         return "\(item.albumArtist) - \(item.albumTitle) : \(item.title)"
    }

    class func addToPlaylist(items:[MPMediaItem]) -> Void {
        for item in items {
           LM.LikedSongs[getHashKey(item)] = item.title
        }
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(LM.LikedSongs, forKey: LIKED_LIST)
        println ("added \(items.count) songs")
        //dumpNSUserDefaults(LIKED_LIST)
    }
    
    class func isLiked(item:MPMediaItem) -> Bool {
        if item != nil {
            if let oldSong = LM.LikedSongs[getHashKey(item)] {
                return true;
            }
        }
        return false;
    }
    
    //MARK: functions for grabbing songs from iTunes
    
     /* run a query to see all items > 1 star in itunes and merge this with current liked */
    class func getLikedSongs() -> [MPMediaItem] {
        scanLibrary()
        let start = NSDate()
        var allLiked = [MPMediaItem]()
        var randomLiked = [MPMediaItem]()
        for (x,y) in LM.LikedSongs {
            if let item = ITunesUtils.getSongFrom(x) {
                allLiked.append(item)
            }
        }
        for x in LM.RatedSongs {
            if let item = ITunesUtils.getSongFrom(x) {
                allLiked.append(item)
            }
        }
        var i = 0
        while i < allLiked.count && i < 50 {
            var idx = Utils.random(allLiked.count-1)
            var item = allLiked[idx]
            randomLiked.append(item)
            println(getSongInfo(item))
            i++
        }
        let time = NSDate().timeIntervalSinceDate(start) * 1000
        println("Built liked list with \(randomLiked.count) songs in \(time)ms")
        LM.Playlist = randomLiked
        return randomLiked
    }
    
    class func getNewSongs() -> [MPMediaItem] {
        scanLibrary()
        var newSongs = [MPMediaItem]()
        let start = NSDate()
        var i = 0
        while i < LM.NotPlayedSongs.count && i < 50 {
            var idx = Utils.random(LM.NotPlayedSongs.count-1)
            if let item = ITunesUtils.getSongFrom(LM.NotPlayedSongs[idx]) {
                newSongs.append(item)
                println(getSongInfo(item))
            }
            i++
        }
        let time = NSDate().timeIntervalSinceDate(start) * 1000
        println("Built new song list with \(newSongs.count) songs in \(time)ms")
        LM.Playlist = newSongs
        return newSongs
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
