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
    
    class func isPlaying() -> Bool {
        //return applePlayer.currentPlaybackRate > 0;
        return MP.applePlayer.playbackState == MPMusicPlaybackState.Playing
    }
    
    class func playPressed() {
        isPlaying() ?  MP.applePlayer.pause() : MP.applePlayer.play()
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
    
    class func play(items: [MPMediaItem], shuffle : Bool = false) {
        if items.count > 0 {
            var coll = MPMediaItemCollection(items: items)
            MP.applePlayer.shuffleMode = MPMusicShuffleMode.Off
            MP.applePlayer.setQueueWithItemCollection(coll)
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
