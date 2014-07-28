import MediaPlayer

private let MP = MusicPlayer()

class MusicPlayer {

    init() {
        applePlayer.beginGeneratingPlaybackNotifications()
    }
    
    private let applePlayer = MPMusicPlayerController()
    private var skipToBegin = false
    
    class func currentSong() -> MPMediaItem! {
        return MP.applePlayer.nowPlayingItem
    }
    
    class func isPlaying() -> Bool {
        //return applePlayer.currentPlaybackRate > 0;
        return MP.applePlayer.playbackState == MPMusicPlaybackState.Playing
    }
    
    class func playPressed() {
        //println ("current state: \(isPlaying()) .. play tapped")
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
    
    class func Play(items: [MPMediaItem]) {
        //MP.applePlayer.setQueueWithItemCollection(items)
    }
}
