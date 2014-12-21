import MediaPlayer

private let MP = MusicPlayer()

class MusicPlayer {

    init() {
        applePlayer.beginGeneratingPlaybackNotifications()
    }
    
    private let applePlayer = MPMusicPlayerController()
    private var skipToBegin = false
    private var queuedPlaylist : [MPMediaItem]?
    private var songToStartOnQueuedPlaylist : MPMediaItem?
    
    class var currentSong : MPMediaItem! {
        get {
            return MP.applePlayer.nowPlayingItem
        }
    }
    
    class var currentTime : NSTimeInterval {
        get {
            return MP.applePlayer.currentPlaybackTime
        }
    }
    
    class var isPlaying : Bool {
        get {
            return MP.applePlayer.currentPlaybackRate > 0;
            //return MP.applePlayer.playbackState == MPMusicPlaybackState.Playing
        }
    }
    
    class func playPressed() {
        isPlaying ?  MP.applePlayer.pause() : MP.applePlayer.play()
    }
    
    class func forward() {
        if MP.queuedPlaylist != nil {
            playSongsInQueue()
            return
        }
        MP.applePlayer.skipToNextItem()
        MP.skipToBegin = false
        MP.applePlayer.play()
    }
    
    class func reverse() {
        if !MP.skipToBegin {
            MP.applePlayer.skipToBeginning()
            MP.skipToBegin = true
            //do a timer
        } else {
            MP.skipToBegin = false
            MP.applePlayer.skipToPreviousItem()
        }
    }
    
    class func play(items: [MPMediaItem]) {
        if items.count > 0 {
            queuePlaylist(items)
            playSongsInQueue()
        }
    }
    
    class func queuePlaylist(songs: [MPMediaItem], songToStart : MPMediaItem? = nil, startNow : Bool = false) {
        MP.queuedPlaylist = songs;
        MP.songToStartOnQueuedPlaylist = songToStart;
        if startNow {
            playSongsInQueue()
        }
    }
    
    class func playSongsInQueue() {
        if MP.queuedPlaylist == nil {
            return;
        }
        println ("MusicPlayer.playSongsInQueue")
        var coll = MPMediaItemCollection(items: MP.queuedPlaylist)
        MP.applePlayer.shuffleMode = MPMusicShuffleMode.Off
        MP.applePlayer.setQueueWithItemCollection(coll)
        //now that we have grabbed the items off the queue, nil it out
        MP.queuedPlaylist = nil
        if let song = MP.songToStartOnQueuedPlaylist {
            playSongInPlaylist(song)
        } else {
            MP.applePlayer.play()
        }
    }
    
    /* if a request comes in to play a song in the playlist but the playlist 
        has not actually been queued ( delayed queing for artist and albums )
        we must first add the playlist into the queue and then set the start item */
    class func playSongInPlaylist(song : MPMediaItem) {
        if MP.queuedPlaylist != nil {
            MP.songToStartOnQueuedPlaylist = song
            playSongsInQueue()
        }
        else {
            MP.applePlayer.nowPlayingItem = song
            MP.applePlayer.play()
        }
    }
    
    class var playbackTime : Int {
        get {
            return Int(MP.applePlayer.currentPlaybackTime)
        }
        set(seconds) {
            MP.applePlayer.currentPlaybackTime = Double(seconds)
        }
    }
    
}
