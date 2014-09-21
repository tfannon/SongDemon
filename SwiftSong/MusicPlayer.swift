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
        MP.applePlayer.skipToNextItem()
        MP.skipToBegin = false
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
    
    class func queuePlaylist(items: [MPMediaItem], itemToStart : MPMediaItem? = nil) {
        MP.queuedPlaylist = items;
        MP.songToStartOnQueuedPlaylist = itemToStart;
    }
    
    class func playSongsInQueue() {
        var coll = MPMediaItemCollection(items: MP.queuedPlaylist)
        MP.applePlayer.shuffleMode = MPMusicShuffleMode.Off
        MP.applePlayer.setQueueWithItemCollection(coll)
        if let song = MP.songToStartOnQueuedPlaylist {
            playSongInPlaylist(song)
        } else {
            MP.applePlayer.play()
        }
    }
    
    class func playSongInPlaylist(song : MPMediaItem) {
        MP.applePlayer.nowPlayingItem = song
        MP.applePlayer.play()
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
