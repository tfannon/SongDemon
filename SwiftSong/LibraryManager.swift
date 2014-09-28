
import MediaPlayer

let LIKED_LIST = "Liked"
let DISLIKED_LIST = "Disliked"
let QUEUED_LIST = "Queued"
private let LM = LibraryManager()


enum LikeState {
    case Liked
    case Disliked
    case None
}

enum PlayMode {
    case Album
    case Artist
    case Mix
    case Liked
    case New
    case None
    case Custom
    case Queued
}

class LibraryManager {
    //the finals are to get around a performance bug where adding items to a dictionary is very slow
    private final var LikedSongs = Dictionary<String,String>()
    private final var DislikedSongs = Dictionary<String,String>()
    private final var QueuedSongs = Dictionary<String,String>()
    //computed at load
    private final var RatedSongs = Array<String>()
    private final var LowRatedSongs = Array<String>()
    private final var NotPlayedSongs = Array<String>()
    private final var OtherSongs = Array<String>()
    private var scanned = false
    //playlist 
    private var Playlist = Array<MPMediaItem>()
    private var GroupedPlaylist = [[MPMediaItem]]()
    private var PlaylistIndex = -1
    private var PlaylistMode = PlayMode.None


    init() {
        println("storage objects being initialized from NSDefaults\n")
        let userDefaults = NSUserDefaults.standardUserDefaults();
        if let result = userDefaults.objectForKey(LIKED_LIST) as? Dictionary<String,String> {
            println("\(result.count) liked songs")
            for (x,y) in result {
               LikedSongs[x] = y
               //println("\(y)")
            }
        }
        if let result = userDefaults.objectForKey(DISLIKED_LIST) as? Dictionary<String,String> {
            println("\(result.count) disliked songs")
            for (x,y) in result {
                DislikedSongs[x] = y
                //println("\(y)")
            }
        }
        if let result = userDefaults.objectForKey(QUEUED_LIST) as? Dictionary<String,String> {
            println("\(result.count) queued songs")
            for (x,y) in result {
                QueuedSongs[x] = y
                //println("\(y)")
            }
        }
        
        println()
    }
    
    //MARK: no class properties yet
    class var currentPlaylist : [MPMediaItem] {
        return LM.Playlist
    }
    
    class var groupedPlaylist : [[MPMediaItem]] {
        return LM.GroupedPlaylist
    }
    
    class var currentPlaylistIndex : Int {
        return LM.PlaylistIndex
    }
    
    class var currentPlayMode : PlayMode {
        return LM.PlaylistMode
    }
    
    class func changePlaylistIndex(currentSong : MPMediaItem) {
        var index = find(LM.Playlist, currentSong)
        if index != nil {
            LM.PlaylistIndex = index!
            println("Setting playlist index to: \(currentSong.songInfo))")
        }
    }
    
    class func scanLibrary() {
        //this is called on a background thread at app start.  make sure that if the user
        //quickly triggers an action which starts another scan, it does not get into this code
        //when it does, the other scan should have flipped the flag so it wont be re-scanned
        objc_sync_enter(LM.LikedSongs)
        if LM.scanned {
            println("lib already scanned")
            return
        }
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
                            LM.LowRatedSongs.append(song.hashKey)
                        default:
                            LM.RatedSongs.append(song.hashKey)
                        }
                    }
                    else if song.playCount >= 0 && song.playCount <= 2 {
                        LM.NotPlayedSongs.append(song.hashKey)
                        unplayed++
                    }
                    else {
                        LM.OtherSongs.append(song.hashKey)
                    }
                }
            }
            let time = NSDate().timeIntervalSinceDate(start) * 1000
            println("Scanned \(allSongs.count) in \(time)ms. \n  \(LM.RatedSongs.count) songs with >1 rating \n  \(LM.LowRatedSongs.count) songs with =1 rating \n  \(unplayed) songs with playcount <2 \n  \(LM.OtherSongs.count) others songs\n")
        }
        LM.scanned = true;
        objc_sync_exit(LM.LikedSongs)
    }
    
    //MARK: typed list functions

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

    //todo; can't one function get both of these?
    class func addToQueued(item: MPMediaItem) {
        addToList(QUEUED_LIST, list: &LM.QueuedSongs, item: item)
    }

    class func addToQueued(items: [MPMediaItem]) {
        addToList(QUEUED_LIST, list: &LM.QueuedSongs, items: items)
    }
    
    class func removeFromQueued(item: MPMediaItem) {
        removeFromList(QUEUED_LIST, list: &LM.QueuedSongs, item: item)
    }
    
    class func removeFromQueued(items: [MPMediaItem]) {
        removeFromList(QUEUED_LIST, list: &LM.QueuedSongs, items: items)
    }
    
    class func clearQueued() {
        LM.QueuedSongs.removeAll(keepCapacity: false)
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(LM.QueuedSongs as Dictionary<NSObject,AnyObject>, forKey: QUEUED_LIST)
    }
    
    class func isLiked(item:MPMediaItem?) -> Bool {
        if item != nil {
            if let song = LM.LikedSongs[item!.hashKey] {
                return true;
            }
        }
        return false;
    }
    
    class func isDisliked(item:MPMediaItem?) -> Bool {
        if item != nil {
            if let song = LM.DislikedSongs[item!.hashKey] {
                return true;
            }
        }
        return false;
    }
    
    //MARK: generic functions which receive their args from public typed functions
    
    private class func addToList(listName:String, inout list:Dictionary<String,String>, item:MPMediaItem?) {
        if (item != nil) {
            list[item!.hashKey] = item!.title
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(list as Dictionary<NSObject,AnyObject>, forKey: listName)
        }
    }
    
    private class func addToList(listName:String, inout list: Dictionary<String,String>, items:[MPMediaItem]) {
        for item in items {
            list[item.hashKey] = item.title
        }
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(list as Dictionary<NSObject,AnyObject>, forKey: listName)
    }
   
    private class func removeFromList(listName:String, inout list:Dictionary<String,String>, item:MPMediaItem?) {
        if (item != nil) {
            list.removeValueForKey(item!.hashKey);
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(list as Dictionary<NSObject,AnyObject>, forKey: listName)
        }
    }
    
    private class func removeFromList(listName:String, inout list: Dictionary<String,String>, items:[MPMediaItem]) {
        for item in items {
            list.removeValueForKey(item.hashKey)
        }
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(list as Dictionary<NSObject,AnyObject>, forKey: listName)
    }
    
    
    //MARK: functions for getting playlists
    
     /* run a query to see all items > 1 star in itunes and merge this with current liked */
    class func getLikedSongs(count : Int = 50, dumpSongs : Bool = true) -> [MPMediaItem] {
        scanLibrary()
        let start = NSDate()
        var allLiked = [MPMediaItem]()
        var randomLiked = [MPMediaItem]()
        LM.GroupedPlaylist = [[MPMediaItem]]()
        for (x,y) in LM.LikedSongs as Dictionary<String,String> {
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
                //println(getSongInfo(item))
                i++
            } else {
                //println("dup detected")
            }
        }
        let time = NSDate().timeIntervalSinceDate(start) * 1000
        if dumpSongs {
            println("Built liked list with \(randomLiked.count) songs in \(time)ms")
            outputSongs(randomLiked)
        }
        LM.Playlist = randomLiked
        LM.GroupedPlaylist.append(randomLiked)
        LM.PlaylistIndex = 0
        LM.PlaylistMode = .Liked
        return randomLiked
    }
    
    class func getNewSongs(count : Int = 50, dumpSongs : Bool = true) -> [MPMediaItem] {
        scanLibrary()
        let start = NSDate()
        LM.GroupedPlaylist = [[MPMediaItem]]()
        var newSongs = getRandomSongs(count, sourceSongs: LM.NotPlayedSongs)
        let time = NSDate().timeIntervalSinceDate(start) * 1000
        if dumpSongs {
            println("Built new song list with \(newSongs.count) songs in \(time)ms")
            outputSongs(newSongs)
        }
        LM.Playlist = newSongs
        LM.GroupedPlaylist.append(newSongs)
        LM.PlaylistIndex = 0
        LM.PlaylistMode = .New
        return newSongs
    }
    
    // 20 new, 20 favs, 10 not new and not rated
    class func getMixOfSongs() -> [MPMediaItem] {
        scanLibrary()
        let start = NSDate()
        var newSongs = getNewSongs(count: 20, dumpSongs:false)
        var ratedSongs = getLikedSongs(count: 20, dumpSongs:false)
        var otherSongs = getRandomSongs(10, sourceSongs: LM.OtherSongs)
        var mixedSongs = Utils.shuffle(newSongs + ratedSongs + otherSongs)
        let time = NSDate().timeIntervalSinceDate(start) * 1000
        println("Built mixed song list with \(mixedSongs.count) songs in \(time)ms")
        outputSongs(mixedSongs)
        LM.GroupedPlaylist = [[MPMediaItem]]()
        LM.Playlist = mixedSongs
        LM.GroupedPlaylist.append(mixedSongs)
        LM.PlaylistIndex = 0
        LM.PlaylistMode = .Mix
        return mixedSongs;
    }
    
    //grab a bunch of songs by current artist
    class func getArtistSongs(currentSong : MPMediaItem?) -> [MPMediaItem] {
        //album->*song
        let stopwatch = Stopwatch()
        LM.Playlist = [MPMediaItem]()
        LM.GroupedPlaylist = [[MPMediaItem]]()
        if currentSong != nil {
            var results = getArtistSongsWithoutSettingPlaylist(currentSong)
            LM.Playlist = results.1
            LM.GroupedPlaylist = results.0
        }
        let time = stopwatch.stop()
        println("Built artist songlist with \(LM.GroupedPlaylist.count) albums and \(LM.Playlist.count) songs in \(time)ms")
        LM.PlaylistIndex = find(LM.Playlist, currentSong!)!
        LM.PlaylistMode = .Artist
        return LM.Playlist
    }
    
    class func getAlbumSongs(currentSong : MPMediaItem?) -> [MPMediaItem] {
        let stopwatch = Stopwatch()
        LM.Playlist = [MPMediaItem]()
        LM.GroupedPlaylist = [[MPMediaItem]]()
        if currentSong != nil {
            LM.Playlist  = getAlbumSongsWithoutSettingPlaylist(currentSong)
            LM.GroupedPlaylist.append(LM.Playlist)
        }
        let time = stopwatch.stop()
        println("Built album songlist with \(LM.GroupedPlaylist.count) albums and \(LM.Playlist.count) songs in \(time)ms")
        LM.PlaylistIndex = find(LM.Playlist, currentSong!)!
        LM.PlaylistMode = .Album
        return LM.Playlist
    }
    
    class func getQueuedSongs() -> [MPMediaItem] {
        LM.GroupedPlaylist = [[MPMediaItem]]()
        var songs = [MPMediaItem]()
        for (x,y) in LM.QueuedSongs {
            if let item = ITunesUtils.getSongFrom(x) {
                songs.append(item)
            }
        }
        LM.Playlist = songs
        LM.GroupedPlaylist.append(songs)
        LM.PlaylistIndex = 0
        LM.PlaylistMode = PlayMode.Queued
        return songs
    }
    
    class func getAlbumSongsWithoutSettingPlaylist(currentSong : MPMediaItem?) -> [MPMediaItem] {
        var songs = [MPMediaItem]()
        if currentSong != nil {
            var query = MPMediaQuery.songsQuery()
            var pred = MPMediaPropertyPredicate(value: currentSong!.albumTitle, forProperty: MPMediaItemPropertyAlbumTitle)
            query.addFilterPredicate(pred)
            var albumSongs = query.items as [MPMediaItem]
            songs = albumSongs.sorted { $0.albumTrackNumber < $1.albumTrackNumber }
            outputSongs(songs)
        }
        return songs
    }
    
    //return tuple of grouped songs and songs
    class func getArtistSongsWithoutSettingPlaylist(currentSong : MPMediaItem?) -> ([[MPMediaItem]], [MPMediaItem]) {
        //album->*song
        var songs = [MPMediaItem]()
        var groupedSongs = [[MPMediaItem]]()
        if currentSong != nil {
            var query = MPMediaQuery.songsQuery()
            var pred = MPMediaPropertyPredicate(value: currentSong!.albumArtist, forProperty: MPMediaItemPropertyAlbumArtist)
            query.addFilterPredicate(pred)
            var artistSongs = query.items as [MPMediaItem]
            var albumDic = Dictionary<String,Array<MPMediaItem>>(minimumCapacity: artistSongs.count)
            //fill up the dictionary with songs
            for x in artistSongs {
                if albumDic.indexForKey(x.albumTitle) == nil {
                    albumDic[x.albumTitle] = Array<MPMediaItem>()
                }
                albumDic[x.albumTitle]?.append(x)
            }
            
            //get them back out by album and insert into array of arrays
            for (x,y) in albumDic {
                var sorted = y.sorted { $0.albumTrackNumber < $1.albumTrackNumber }
                groupedSongs.append(sorted)
            }
            //now sort the grouped playlist by year
            groupedSongs.sort { $0[0].year > $1[0].year }
            //now add all the groupplaylist into one big playlist for the media player
            for album in groupedSongs {
                songs.extend(album)
            }
            outputSongs(songs)
        }
        return (groupedSongs, songs)
    }
    
    
    class func makePlaylistFromSongs(songs: [MPMediaItem]) {
        LM.GroupedPlaylist = [[MPMediaItem]]()
        LM.Playlist = songs
        LM.GroupedPlaylist.append(songs)
        LM.PlaylistIndex = 0
        LM.PlaylistMode = .Custom
    }
    
    /*
    Artist mode -> pull to refresh will shuffle
    Album mode -> pull to refresh will shuffle
    Mix mode -> pull to refresh will fetch different songs
    */
    
    //MARK: private helper functions

    private class func getRandomSongs(count : Int, sourceSongs : [String]) -> [MPMediaItem] {
        var randomSongs = [MPMediaItem]()
        var songsPicked = 0
        var i = 0
        while i < sourceSongs.count && songsPicked < count {
            var idx = Utils.random(sourceSongs.count-1)
            if let item = ITunesUtils.getSongFrom(sourceSongs[idx]) {
                //if it hasnt been disliked or already added
                if !isDisliked(item) && find(randomSongs, item) == nil {
                    randomSongs.append(item)
                    songsPicked++
                }
            }
            i++
        }
        return randomSongs
    }
    
    private class func outputSongs(songs: [MPMediaItem]) {
        for i in songs {
            println(i.songInfo)
        }
        println()
    }
    

    private class func dumpNSUserDefaults(forList:String) -> Void {
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let songsFromDefaults = userDefaults.objectForKey(forList) as? Dictionary<String,String> {
            println("Current defaults: \(songsFromDefaults)")
        } else {
            println("No userDefaults")
        }
    }
}
