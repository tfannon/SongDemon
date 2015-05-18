//
//  InterfaceController.swift
//  SongDemon WatchKit Extension
//
//  Created by Tommy Fannon on 5/4/15.
//  Copyright (c) 2015 crazy8dev. All rights reserved.
//

import WatchKit
import Foundation
import MediaPlayer


class InterfaceController: WKInterfaceController {
    
    var playMode = PlayMode.Mix
    var simulatorPlaying = true
    let STEPS = 5
    
    //MARK: WKInterfaceController methods
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        slider.setNumberOfSteps(STEPS)
        self.playCountLabel.setText("")
        // Configure interface objects here.
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        updateSongInfo()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    
    //MARK: - outlets
    @IBOutlet weak var artistLabel: WKInterfaceLabel!
    @IBOutlet weak var songLabel: WKInterfaceLabel!
    //this holds the artist songs
    @IBOutlet weak var playCountLabel: WKInterfaceLabel!

    
    @IBOutlet weak var prevButton: WKInterfaceButton!
    @IBOutlet weak var playButton: WKInterfaceButton!
    @IBOutlet weak var nextButton: WKInterfaceButton!
    
    @IBOutlet weak var slider: WKInterfaceSlider!

    //MARK: - actions
    @IBAction func prevPressed() {
        let player = MPMusicPlayerController()
        player.skipToPreviousItem()
        player.play()
        updateSongInfo()
    }
    
    
    @IBAction func playPressed() {
        let player = MPMusicPlayerController()
        if player.nowPlayingItem == nil {
            playMix()
        }
        switch (player.playbackState) {
            case (MPMusicPlaybackState.Playing) : player.pause()
            case (MPMusicPlaybackState.Paused) : player.play()
            default : ""
        }
        updatePlayState()
    }
    
    @IBAction func nextPressed() {
        skipToNextSong()
    }
   
  
    @IBAction func thumbsUpPressed() {
        LibraryManager.addToLiked(MusicPlayer.currentSong)
        songLabel.setTextColor(UIColor.whiteColor())
    }
    
    @IBAction func thumbsDownPressed() {
        LibraryManager.addToDisliked(MusicPlayer.currentSong)
        skipToNextSong()
    }
    
    //this will force the phone to regenerate the lists
    @IBAction func shufflePressed() {
        LibraryManager.generatePlaylistsForWatch(true)
        switch playMode {
        case .Mix : playMix()
        case .Artist: playArtist()
        case .Liked: playLiked()
        default:""
        }
    }
    
    //MARK: context menu items
    @IBAction func likeTapped() {
        self.playMode = .Liked
        playLiked()
    }
    
    @IBAction func mixTapped() {
        self.playMode = .Mix
        playMix()
    }
    
    @IBAction func artistTapped() {
        self.playMode = .Artist
        playArtist()
    }
    
    @IBAction func discoverTapped() {
        self.playMode = .New
        playNew()
    }
    
    //MARK: scrubber
    var timer = NSTimer()
    func startPlaybackTimer() {
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:"updateScrubber", userInfo:nil, repeats:true)
    }
    
    func updateScrubber() {
        //110, 30, 10
        let curStep = getCurrentStep()
        //println("Total:\(tot)  Current:\(cur),  TimePerStep:\(timePerStep)  Slot:\(curStep)")
        slider.setValue(Float(curStep))
    }
    
    func getCurrentStep() -> Int {
        let cur : Int = Int(MusicPlayer.currentTime)
        let tot : Int = Int(MusicPlayer.currentSong.playbackDuration)
        let timePerStep = Int(tot/STEPS)
        let curStep = Int(cur/timePerStep)+1
        return curStep
    }
    
    @IBAction func volumeSliderChanged(value: Float) {
        let curStep = getCurrentStep()
        let nextStep = Int(value)
        let diff = nextStep - curStep
        
        
        let tot : Int = Int(MusicPlayer.currentSong.playbackDuration)
        let cur : Int = Int(MusicPlayer.currentTime)  //25   190
        let timePerStep = Int(tot/STEPS) //200 / 5 = 40
        let next = cur + (diff * timePerStep) //25 + 40 = 65       190+40 = 235
        println("Current:\(cur),  diff:\(diff)  next:\(next)")

        if next == 0 {
            let player = MPMusicPlayerController()
            player.skipToBeginning()
            startPlaybackTimer()
        }
        if next < tot && next > 0 {
            MusicPlayer.playbackTime = next
            startPlaybackTimer()
        }
    }
    
    //MARK: helpers
    func skipToNextSong() {
        let player = MPMusicPlayerController()
        player.skipToNextItem()
        player.play()
        updateSongInfo()
    }
    
    
    func updateSongInfo() {
        let player = MPMusicPlayerController()
        if let item = player.nowPlayingItem {
            artistLabel.setText(item.albumArtist)
            songLabel.setText(item.title)
            //playCountLabel.setText("\(item.playCount)")
            if isLiked(item.hashKey) {
                songLabel.setTextColor(.whiteColor())
            }
            else {
                songLabel.setTextColor(.grayColor())
            }
            startPlaybackTimer()
        }
        else if !Utils.inSimulator {
            artistLabel.setText("")
            songLabel.setText("")
        }
        updatePlayState()
    }
    
    func updatePlayState() {
        if Utils.inSimulator {
            simulatorPlaying = !simulatorPlaying
            if simulatorPlaying {
                playButton.setBackgroundImageNamed("note")
            }
            else {
               playButton.setBackgroundImageNamed("pause")
            }
            return
        }

        let player = MPMusicPlayerController()
        switch (player.playbackState) {
            case (.Playing) : playButton.setBackgroundImageNamed("note")
            default: playButton.setBackgroundImageNamed("pause")
        }
    }
    
    func isLiked(id : String) -> Bool {
        let defaults = Utils.AppGroupDefaults
        //this is not quite right because it checks in the playlist that was written to defaults
        //not the one computed at Library Init
        if let ids = defaults.objectForKey(WK_LIKED_PLAYLIST) as? [String] {
            if find(ids, id) != nil {
                return true
            }
        }
        return false
    }
    
    
    func playMix() {
        self.setTitle("MIX")
        self.playCountLabel.setText("")
        playList(WK_MIX_PLAYLIST)
    }
    
    func playLiked() {
        self.setTitle("LIKED")
        self.playCountLabel.setText("")
        playList(WK_LIKED_PLAYLIST)
    }
    
    func playNew() {
        self.setTitle("NEW")
        self.playCountLabel.setText("")
        playList(WK_NEW_PLAYLIST)
    }
    
    func playList(listName : String) {
        let defaults = Utils.AppGroupDefaults
        if let ids = defaults.objectForKey(listName) as? [String] {
            var songs = ITunesUtils.getSongsFrom(ids)
            if songs.count > 0 {
                songs.shuffle()
                MusicPlayer.queuePlaylist(songs, songToStart: nil, startNow: true)
                updateSongInfo()
            }
        }
    }

    
    func playArtist() {
        self.setTitle("ARTIST")
        let player = MPMusicPlayerController()
        let defaults = Utils.AppGroupDefaults
        
        if let artist = player.nowPlayingItem?.albumArtist {
            if let ids = defaults.objectForKey(artist) as? [String] {
                var songs = ITunesUtils.getSongsFrom(ids)
                if songs.count > 0 {
                    playCountLabel.setText("\(songs.count)")
                    songs.shuffle()
                    MusicPlayer.queuePlaylist(songs, songToStart: nil, startNow: true)
                    updateSongInfo()
                }
            }
        }
    }
    
//    func refreshListFromPhone(listName : String) {
//        LibraryManager.generatePlaylistsForWatch(true)
//        let request = ["action":listName]
//        WKInterfaceController.openParentApplication(request) { reply, error in
//            println("User Info: \(reply)")
//            println("Error: \(error)")
//            if error == nil {
//                self.playList(listName, refreshList: false)
//            }
//        }
//    }
}
