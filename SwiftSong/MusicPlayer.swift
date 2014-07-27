import MediaPlayer


class MusicPlayer {
    struct Static {
        static var instance: MusicPlayer?
    }

    init() {
        applePlayer.beginGeneratingPlaybackNotifications()
    }
    
    class func get() -> MusicPlayer {
        if !Static.instance {
            Static.instance = MusicPlayer()
        }
        return Static.instance!
    }
    
    let applePlayer = MPMusicPlayerController()
    var skipToBegin = false
    
    func currentSong() -> MPMediaItem! {
        return applePlayer.nowPlayingItem
    }
    
    func isPlaying() -> Bool {
        //return applePlayer.currentPlaybackRate > 0;
        return applePlayer.playbackState == MPMusicPlaybackState.Playing
    }
    
    func playPressed() {
        //println ("current state: \(isPlaying()) .. play tapped")
        isPlaying() ?  applePlayer.pause() : applePlayer.play()
    }
    
    func forward() {
        applePlayer.skipToNextItem()
        skipToBegin = false
    }
    
    func reverse() {
        if !skipToBegin {
            applePlayer.skipToBeginning()
            skipToBegin = true
            //do a timer
        } else {
            skipToBegin = false
            applePlayer.skipToPreviousItem()
        }
    }
    
}
