
import MediaPlayer

let RECENTLY_ADDED_LIST = "RecentlyAdded"
let DISLIKED_LIST = "Disliked"
let QUEUED_LIST = "Queued"
let CURRENT_LIST = "Current"
let LIKED_LIST = "Liked"


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

class ArtistInfo {
    //var artwork : MPMediaItemArtwork?
    var itunesId: String!
    var songs: Int = 0
    var likedSongs: Int = 0
    var unplayedSongs: Int = 0
    var songIds = [String]()
}

protocol LibraryScanListener {
    func libraryScanComplete() -> Void
}

class LibraryManager {
    //the finals are to get around a performance bug where adding items to a dictionary is very slow
    private final var LikedSongs = Dictionary<String,String>()
    private final var DislikedSongs = Dictionary<String,String>()
    private final var QueuedSongs = Dictionary<String,String>()
    private final var ArtistInfos = Dictionary<String,ArtistInfo>()
    private var songCount = 0
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

    private var LibraryScanListeners = [LibraryScanListener]()


    init() {
        let stopwatch = Stopwatch.start("LibraryManager.init")
        let userDefaults = Utils.AppGroupDefaults;
        if let result = userDefaults.objectForKey(LIKED_LIST) as? Dictionary<String,String> {
            print("\(result.count) liked songs")
            LikedSongs = result
            //result.map { println($0) }
        }
        if let result = userDefaults.objectForKey(DISLIKED_LIST) as? Dictionary<String,String> {
            print("\(result.count) disliked songs")
            DislikedSongs = result
        }
        if let result = userDefaults.objectForKey(QUEUED_LIST) as? Dictionary<String,String> {
            print("\(result.count) queued songs")
            QueuedSongs = result
        }
        stopwatch.stop("")
    }
    
        
    //MARK: computed class properties
    
    class var songCount : Int {
        return LM.songCount
    }
    
    class var currentPlaylist : [MPMediaItem] {
        return LM.Playlist
    }
    
    class var artistInfo : Dictionary<String,ArtistInfo> {
        return LM.ArtistInfos
    }
    
    static func hasArtist(name: String) -> Bool {
        return LM.ArtistInfos[name] != nil
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
    
    //MARK: library scanning
    
    class func addListener(listener : LibraryScanListener) {
        LM.LibraryScanListeners.append(listener)
    }
    
    class func scanLibrary() {
        //this is called on a background thread at app start.  make sure that if the user
        //quickly triggers an action which starts another scan, it does not get into this code
        //when it does, the other scan should have flipped the flag so it wont be re-scanned
        if LM.scanned {
            print("lib already scanned")
            return
        }
        var unplayed = 0;

        objc_sync_enter(LM.LikedSongs)
        cleanPlaylists()
        let stopwatch = Stopwatch.start("scanLibrary")
        
        if let allSongs = ITunesUtils.getAllSongs() {
            LM.songCount = allSongs.count
            for song in allSongs {
                if let artist = song.albumArtist {
                    var artistInfo : ArtistInfo? = LM.ArtistInfos[artist]
                    //grab some artwork
                    if artistInfo == nil {
                        artistInfo = ArtistInfo()
                        artistInfo?.itunesId = song.artistHashKey
                        LM.ArtistInfos[artist] = artistInfo
                    }
//                    if artistInfo!.artwork == nil {
//                        artistInfo!.artwork = song.artwork
//                    }
                    //increment number of songs in library
                    artistInfo!.songs++

                    //an album must have an album artist and title and a rating to make the cut
                    if song.albumArtist != nil && song.title != nil {
                        var disliked = LM.DislikedSongs[song.hashKey] != nil

                        if song.rating >= 1 {
                            switch (song.rating) {
                            case 0:""
                            //we take 1 star to mean disliked in itunes
                            case 1:
                                disliked = true
                                LM.LowRatedSongs.append(song.hashKey)
                            //any rating > 1 qualifies
                            default:
                                LM.RatedSongs.append(song.hashKey)
                                artistInfo!.likedSongs++

                            }
                        }
                        else if song.playCount >= 0 && song.playCount <= 2 {
                            LM.NotPlayedSongs.append(song.hashKey)
                            unplayed++
                            artistInfo!.unplayedSongs++
                        }
                        else {
                            LM.OtherSongs.append(song.hashKey)
                        }
                        if !disliked {
                            artistInfo!.songIds.append(song.hashKey)
                        }
                    }
                }
            }
            stopwatch.stop("Scanned \(allSongs.count) songs\n  \(LM.RatedSongs.count) songs with >1 rating \n  \(LM.LowRatedSongs.count) songs with =1 rating \n  \(unplayed) songs with playcount <2 \n  \(LM.OtherSongs.count) others songs\n")
        }
        LM.scanned = true;
        objc_sync_exit(LM.LikedSongs)
        for x in LM.LibraryScanListeners {
            x.libraryScanComplete()
        }
        //generatePlaylistsForWatch(true)
    }
    
    //MARK: functions for adding to lists

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
        let userDefaults = Utils.AppGroupDefaults
        userDefaults.setObject(LM.QueuedSongs as Dictionary<NSObject,AnyObject>, forKey: QUEUED_LIST)
    }
    
    class func isLiked(item:MPMediaItem?) -> Bool {
        return item != nil && LM.LikedSongs[item!.hashKey] != nil
    }
    
    class func isDisliked(item:MPMediaItem?) -> Bool {
        return item != nil && LM.DislikedSongs[item!.hashKey] != nil
    }
    
    
    //MARK: private list helpers
    
    //key is PersistentId but since persistent id can change we will store the other parts so we can 
    //do a reverse lookup in the event we need to rebuild the lists
    private class func addToList(listName:String, inout list:Dictionary<String,String>, item:MPMediaItem?) {
        if let song = item {
            let val = "\(song.albumArtist):\(song.albumTitle):\(song.title)"
            list[song.hashKey] = val
            let userDefaults = Utils.AppGroupDefaults
            userDefaults.setObject(list as Dictionary<NSObject,AnyObject>, forKey: listName)
        }
    }
    
    private class func addToList(listName:String, inout list: Dictionary<String,String>, items:[MPMediaItem]) {
        for item in items {
            list[item.hashKey] = item.title
        }
        let userDefaults = Utils.AppGroupDefaults
        userDefaults.setObject(list as Dictionary<NSObject,AnyObject>, forKey: listName)
    }
   
    private class func removeFromList(listName:String, inout list:Dictionary<String,String>, item:MPMediaItem?) {
        if (item != nil) {
            list.removeValueForKey(item!.hashKey);
            let userDefaults = Utils.AppGroupDefaults
            userDefaults.setObject(list as Dictionary<NSObject,AnyObject>, forKey: listName)
        }
    }
    
    private class func removeFromList(listName:String, inout list: Dictionary<String,String>, items:[MPMediaItem]) {
        for item in items {
            list.removeValueForKey(item.hashKey)
        }
        let userDefaults = Utils.AppGroupDefaults
        userDefaults.setObject(list as Dictionary<NSObject,AnyObject>, forKey: listName)
    }
    
    
    //MARK: functions for getting playlists
    
     /* run a query to see all items > 1 star in itunes and merge this with current liked */
    class func getLikedSongs(count : Int = 50, dumpSongs : Bool = false) -> [MPMediaItem] {
        scanLibrary()
         let sw = Stopwatch.start()
        //take all the SongDemon liked songs
        var allLiked : [String] = LM.LikedSongs.keys.map { $0 }
        //add all the iTunes-rated songs
        allLiked.appendContentsOf(LM.RatedSongs)
        //grab n randomly
        let randomLiked = getRandomSongs(count, sourceSongs: allLiked)
        sw.stop("Built liked list with \(randomLiked.count) songs")
        if dumpSongs {
            outputSongs(randomLiked)
        }
        LM.Playlist = randomLiked
        LM.GroupedPlaylist = [[MPMediaItem]](arrayLiteral: randomLiked)
        LM.PlaylistIndex = 0
        LM.PlaylistMode = .Liked
        return randomLiked
    }
    
    class func getNewSongs(count : Int = 50, dumpSongs : Bool = false) -> [MPMediaItem] {
        scanLibrary()
        let start = NSDate()
        LM.GroupedPlaylist = [[MPMediaItem]]()
        let newSongs = getRandomSongs(count, sourceSongs: LM.NotPlayedSongs)
        let time = NSDate().timeIntervalSinceDate(start) * 1000
        if dumpSongs {
            print("Built new song list with \(newSongs.count) songs in \(time)ms")
            outputSongs(newSongs)
        }
        LM.Playlist = newSongs
        LM.GroupedPlaylist.append(newSongs)
        LM.PlaylistIndex = 0
        LM.PlaylistMode = .New
        return newSongs
    }
    
    class func getMixOfSongs(count : Int = 50, dumpSongs : Bool = false) -> [MPMediaItem] {
        scanLibrary()
        let sw = Stopwatch.start()
        let allSongs = LM.RatedSongs + LM.NotPlayedSongs + LM.OtherSongs
        let randomSongs = getRandomSongs(count, sourceSongs: allSongs)
        sw.stop("Built mix list with \(randomSongs.count) songs")

        if dumpSongs {
            outputSongs(randomSongs)
        }
        LM.GroupedPlaylist = [[MPMediaItem]](arrayLiteral: randomSongs)
        LM.Playlist = randomSongs
        LM.PlaylistIndex = 0
        LM.PlaylistMode = .Mix
        return randomSongs;
    }
    
    class func getRecentlyAdded() -> [MPMediaItem] {
        scanLibrary()
        let start = NSDate()
        var songs = [MPMediaItem]()
        let itunesPlaylists = ITunesUtils.getPlaylists([RECENTLY_ADDED_LIST])
        if let recent = itunesPlaylists[RECENTLY_ADDED_LIST] {
            for x in recent {
                if let song = ITunesUtils.getSongFrom(x) {
                    songs.append(song)
                }
            }
        }
        let time = NSDate().timeIntervalSinceDate(start) * 1000
        print("Built recently added song list with \(songs.count) songs in \(time)ms")
        //makePlaylistFromSongs(songs, c nil)
        return songs
    }

    
    //grab a bunch of songs by current artist
    class func getArtistSongs(currentSong : MPMediaItem?) -> [MPMediaItem] {
        //album->*song
        let stopwatch = Stopwatch()
        LM.Playlist = [MPMediaItem]()
        LM.GroupedPlaylist = [[MPMediaItem]]()
        if currentSong != nil {
            (LM.GroupedPlaylist, LM.Playlist) = getArtistSongsWithoutSettingPlaylist(currentSong)
        }
        let time = stopwatch.stop()
        print("Built artist songlist with \(LM.GroupedPlaylist.count) albums and \(LM.Playlist.count) songs in \(time)ms")
        LM.PlaylistIndex = LM.Playlist.indexOf(currentSong!)!
        LM.PlaylistMode = .Artist
        return LM.Playlist
    }
    
    //this services the search functionality which has selected a song via the artist/album picker
    class func setPlaylistFromSearch(songsForPlaylist : [[MPMediaItem]], songsForQueue : [MPMediaItem], songToStart : MPMediaItem) {
        LM.PlaylistMode = .Artist
        LM.Playlist = songsForQueue
        LM.GroupedPlaylist = songsForPlaylist
        LM.PlaylistIndex = LM.Playlist.indexOf(songToStart)!
        MusicPlayer.queuePlaylist(songsForQueue, songToStart: songToStart, startNow: true)
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
        print("Built album songlist with \(LM.GroupedPlaylist.count) albums and \(LM.Playlist.count) songs in \(time)ms")
        LM.PlaylistIndex = LM.Playlist.indexOf(currentSong!)!
        LM.PlaylistMode = .Album
        return LM.Playlist
    }
    
    class func getQueuedSongs() -> [MPMediaItem] {
        LM.GroupedPlaylist = [[MPMediaItem]]()
//        var songs = [MPMediaItem]()
        let songs: [MPMediaItem] = LM.QueuedSongs.map { ITunesUtils.getSongFrom($0.0)! }
//        for (x,_) in LM.QueuedSongs {
//            if let item = ITunesUtils.getSongFrom(x) {
//                songs.append(item)
//            }
//        }
        LM.Playlist = songs
        LM.GroupedPlaylist.append(songs)
        LM.PlaylistIndex = 0
        LM.PlaylistMode = PlayMode.Queued
        return songs
    }
    

    class func makePlaylistFromSongs(songs: [MPMediaItem]) {
        LM.GroupedPlaylist = [[MPMediaItem]]()
        LM.Playlist = songs
        LM.GroupedPlaylist.append(songs)
        LM.PlaylistIndex = 0
        LM.PlaylistMode = .Custom
    }
    
    class func getAlbumSongsWithoutSettingPlaylist(currentSong : MPMediaItem?) -> [MPMediaItem] {
        var songs = [MPMediaItem]()
        if currentSong != nil {
            let query = MPMediaQuery.songsQuery()
            let pred = MPMediaPropertyPredicate(value: currentSong!.albumTitle, forProperty: MPMediaItemPropertyAlbumTitle)
            query.addFilterPredicate(pred)
            let albumSongs = query.items as [MPMediaItem]!
            songs = albumSongs.sort { $0.albumTrackNumber < $1.albumTrackNumber }
            outputSongs(songs)
        }
        return songs
    }
    
    
    class func getArtistSongsWithoutSettingPlaylist(currentSong : MPMediaItem?) -> ([[MPMediaItem]], [MPMediaItem]) {
        if currentSong != nil {
            return getArtistSongsWithoutSettingPlaylist(currentSong!.albumArtist!)
        }
        return ([[MPMediaItem]](),[MPMediaItem]())
    }
    
    //return tuple of grouped songs and songs
    class func getArtistSongsWithoutSettingPlaylist(artist : String) -> ([[MPMediaItem]], [MPMediaItem]) {
        print("getArtistSongs")
        //album->*song
        var songs = [MPMediaItem]()
        var groupedSongs = [[MPMediaItem]]()
        
        let query = MPMediaQuery.songsQuery()
        let pred = MPMediaPropertyPredicate(value: artist, forProperty: MPMediaItemPropertyAlbumArtist)
        query.addFilterPredicate(pred)
        let artistSongs = query.items as [MPMediaItem]!
        var albumDic = [String:[MPMediaItem]](minimumCapacity: artistSongs.count)
        //fill up the dictionary with songs
        for x in artistSongs {
            if albumDic.indexForKey(x.albumTitle!) == nil {
                albumDic[x.albumTitle!] = [MPMediaItem]()
            }
            albumDic[x.albumTitle!]?.append(x)
        }
        
        //get them back out by album and insert into array of arrays
        for (_,y) in albumDic {
            let sorted = y.sort { $0.albumTrackNumber < $1.albumTrackNumber }
            groupedSongs.append(sorted)
        }
        //now sort the grouped playlist by year
        groupedSongs.sortInPlace { $0[0].year > $1[0].year }
        //now add all the groupplaylist into one big playlist for the media player
        for album in groupedSongs {
            songs.appendContentsOf(album)
        }
        //outputSongs(songs)
        return (groupedSongs, songs)
    }
    
    class func changePlaylistIndex(currentSong : MPMediaItem) {
        let index = LM.Playlist.indexOf(currentSong)
        if index != nil {
            LM.PlaylistIndex = index!
            print("Setting playlist index to: \(currentSong.songInfo))")
        }
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
            let idx = Utils.random(sourceSongs.count)
            if let item = ITunesUtils.getSongFrom(sourceSongs[idx]) {
                //if it hasnt been disliked or already added
                if !isDisliked(item) && randomSongs.indexOf(item) == nil {
                    randomSongs.append(item)
                    songsPicked++
                }
            }
            else {
                print("Cannot find \(sourceSongs[idx]) in iTunes")
            }
            i++
        }
        return randomSongs
    }
    
    private class func outputSongs(songs: [MPMediaItem]) {
        for i in songs {
            print(i.songInfo)
        }
        print("")
    }
    

    private class func dumpNSUserDefaults(forList:String) -> Void {
        let userDefaults = Utils.AppGroupDefaults
        if let songsFromDefaults = userDefaults.objectForKey(forList) as? Dictionary<String,String> {
            print("Current defaults: \(songsFromDefaults)")
        } else {
            print("No userDefaults")
        }
    }
    
  
    
    //MARK: functions for generating playlists for watch
    class func serializePlaylist(serializeKey : String, songs : [MPMediaItem]) {
        let ids : [String] = songs.map { song in
            song.hashKey
        }
        if ids.count > 0 {
            let userDefaults = Utils.AppGroupDefaults;
            userDefaults.setObject(ids, forKey: serializeKey)
        }
    }

    class func trimList(listName : String, inout list : [String:String]) {
        let defaults = Utils.AppGroupDefaults
        let trimmed = list.filter { ITunesUtils.getSongFrom($0.0) != nil }
        defaults.setObject(trimmed, forKey: listName)
    }
    
    class func cleanPlaylists() {
        let sw = Stopwatch.start("cleanPlaylists")
        trimList(LIKED_LIST, list: &LM.LikedSongs)
        trimList(DISLIKED_LIST, list: &LM.DislikedSongs)
        trimList(QUEUED_LIST, list: &LM.QueuedSongs)
        sw.stop()
    }
    
    class func generatePlaylistsForWatch(regenerate : Bool) {
        let stopwatch = Stopwatch.start("generatePlaylistsForWatch")
        let defaults = Utils.AppGroupDefaults
        if regenerate || defaults.objectForKey(WK_MIX_PLAYLIST) == nil {
            print("Generating mix for the watch")
            let mix = LibraryManager.getMixOfSongs(200)
            LibraryManager.serializePlaylist(WK_MIX_PLAYLIST, songs: mix)
        }
        
        if regenerate || defaults.objectForKey(WK_LIKED_PLAYLIST) == nil {
            print("Generating liked list for the watch")
            let liked = LibraryManager.getLikedSongs(200)
            LibraryManager.serializePlaylist(WK_LIKED_PLAYLIST, songs: liked)
        }
        
        if regenerate || defaults.objectForKey(WK_NEW_PLAYLIST) == nil {
            print("Generating new list for the watch")
            let new = LibraryManager.getNewSongs(200)
            LibraryManager.serializePlaylist(WK_NEW_PLAYLIST, songs: new)
        }
        var count = 0
        if regenerate || defaults.objectForKey(WK_ARTIST_PLAYLIST) == nil {
            print("Generating artist lists for the watch")
            for (artist,info) in LM.ArtistInfos {
                if info.songIds.count > 0 {
                    count++
                    defaults.setObject(info.songIds, forKey: artist)
                }
            }
        }
        stopwatch.stop("\(count) artists written")
    }

    class func getArtistPlaylistForWatch(artist: String, regenerate : Bool) -> [String] {
        let songs = LibraryManager.getArtistSongsWithoutSettingPlaylist(artist).1
        let ids = songs.map { $0.hashKey }
        return ids
    }
}
