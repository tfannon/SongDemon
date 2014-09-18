import MediaPlayer

private let MP = MusicPlayer()

class MusicPlayer {

    init() {
        applePlayer.beginGeneratingPlaybackNotifications()
    }
    
    private let applePlayer = MPMusicPlayerController()
    private var skipToBegin = false
    
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
    
    /* 
    right now this is a hack.  the item to start is passed in, it means
    that we should not automatically change the playing item as the playlist
    changes.  so we remember the song and the time, set the queue, and then move
    the queue.  this results in a delay since setting the queue stops the song, loses
    the position, and updates the slider.   a better fix would be to set a method
    on the main controller defers the setting of playlist until current song ends.
    */
    class func play(items: [MPMediaItem], itemToStart:MPMediaItem?=nil,
        timeToStart:NSTimeInterval?=nil) {
        if items.count > 0 {
            var coll = MPMediaItemCollection(items: items)
            MP.applePlayer.shuffleMode = MPMusicShuffleMode.Off
            MP.applePlayer.setQueueWithItemCollection(coll)
            var wasPlaying = isPlaying
            if itemToStart != nil {
                MP.applePlayer.nowPlayingItem = itemToStart!
                MP.applePlayer.currentPlaybackTime = timeToStart!
                if wasPlaying {
                    MP.applePlayer.play()
                }

            } else {
                MP.applePlayer.play()
            }
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
