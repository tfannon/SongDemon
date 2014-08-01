
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
    private final var OtherSongs = Array<String>()
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
                        default:
                            LM.RatedSongs.append(getHashKey(song))
                        }
                    }
                    else if song.playCount >= 0 && song.playCount <= 2 {
                        LM.NotPlayedSongs.append(getHashKey(song))
                        unplayed++
                    }
                    else {
                        LM.OtherSongs.append(getHashKey(song))
                    }
                }
            }
            let time = NSDate().timeIntervalSinceDate(start) * 1000
            println("Scanned \(allSongs.count) in \(time)ms. \n  \(LM.RatedSongs.count) songs with >1 rating \n  \(LM.LowRatedSongs.count) songs with =1 rating \n  \(unplayed) songs with playcount <2 \n  \(LM.OtherSongs.count) others songs\n")
        }
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
    
    private class func getSongInfo(item:MPMediaItem) -> String {
         return "\(item.albumArtist) - \(item.albumTitle) : \(item.title)"
    }

    class func addToPlaylist(items:[MPMediaItem]) -> Void {
        for item in items {
           LM.LikedSongs[getHashKey(item)] = item.title
        }
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(LM.LikedSongs, forKey: LIKED_LIST)
        println ("added \(items.count) songs")
    }
    
    class func isLiked(item:MPMediaItem) -> Bool {
        if item != nil {
            if let song = LM.LikedSongs[getHashKey(item)] {
                return true;
            }
        }
        return false;
    }
    
    class func isDisliked(item:MPMediaItem) -> Bool {
        if item != nil {
            if let song = LM.DislikedSongs[getHashKey(item)] {
                return true;
            }
        }
        return false;
    }
    
    
    //MARK: functions for grabbing songs from iTunes
    
     /* run a query to see all items > 1 star in itunes and merge this with current liked */
    class func getLikedSongs(count : Int = 50) -> [MPMediaItem] {
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
                //if it was in our disliked list do NOT include it even if rated
                if !isDisliked(item) {
                    allLiked.append(item)
                }
            }
        }
        var i = 0
        while i < allLiked.count && i < count {
            var idx = Utils.random(allLiked.count-1)
            var item = allLiked[idx]
            //make sure it has not already been added
            if find(randomLiked, item) == nil {
                randomLiked.append(item)
                println(getSongInfo(item))
                i++
            } else {
                //println("dup detected")
            }
        }
        let time = NSDate().timeIntervalSinceDate(start) * 1000
        println("Built liked list with \(randomLiked.count) songs in \(time)ms")
        LM.Playlist = randomLiked
        return randomLiked
    }
    
    class func getNewSongs(count : Int = 50) -> [MPMediaItem] {
        scanLibrary()
        let start = NSDate()
        var newSongs = getRandomSongs(count, sourceSongs: LM.NotPlayedSongs)
        let time = NSDate().timeIntervalSinceDate(start) * 1000
        println("Built new song list with \(newSongs.count) songs in \(time)ms")
        LM.Playlist = newSongs
        return newSongs
    }
    
    // 20 new, 20 favs, 10 not new and not rated
    class func getMixOfSongs() -> [MPMediaItem] {
        scanLibrary()
        let start = NSDate()
        var newSongs = getNewSongs(count: 20)
        var ratedSongs = getLikedSongs(count: 20)
        var otherSongs = getRandomSongs(10, sourceSongs: LM.OtherSongs)
        var mixedSongs = Utils.shuffle(newSongs + ratedSongs + otherSongs)
        let time = NSDate().timeIntervalSinceDate(start) * 1000
        println("Built mixed song list with \(mixedSongs.count) songs in \(time)ms")
        LM.Playlist = mixedSongs
        return mixedSongs;
    }

    private class func getRandomSongs(count : Int, sourceSongs : [String]) -> [MPMediaItem] {
        var randomSongs = [MPMediaItem]()
        var i = 0
        while i < sourceSongs.count && i < count {
            var idx = Utils.random(sourceSongs.count-1)
            if let item = ITunesUtils.getSongFrom(sourceSongs[idx]) {
                //if it hasnt been disliked or already added
                if !isDisliked(item) && find(randomSongs, item) == nil {
                    randomSongs.append(item)
                    println(getSongInfo(item))
                    i++
                } else {
                    //println("dup detected")
                }
            }
        }
        return randomSongs
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
