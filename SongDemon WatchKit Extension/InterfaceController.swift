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

enum PlayMode {
    case Liked
    case Mix
    case Artist
}

class InterfaceController: WKInterfaceController {
    
    var playMode = PlayMode.Mix
    
    //MARK: - outlets and actions
    @IBOutlet weak var prevButton: WKInterfaceButton!
    @IBAction func prevPressed() {
        let player = MPMusicPlayerController()
        player.skipToPreviousItem()
        player.play()
        updateSongInfo()
    }
    
    @IBOutlet weak var playButton: WKInterfaceButton!
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
    
    @IBOutlet weak var nextButton: WKInterfaceButton!
    @IBAction func nextPressed() {
        let player = MPMusicPlayerController()
        player.skipToNextItem()
        player.play()
        updateSongInfo()
    }
    
    @IBOutlet weak var artistLabel: WKInterfaceLabel!
    @IBOutlet weak var songLabel: WKInterfaceLabel!
    
    //this will force a new playlist
    @IBAction func shufflePressed() {
        switch playMode {
        case .Mix : playMix(refreshList: true)
        case .Artist: playArtist()
        case .Liked: playLiked(refreshList: true)
        default:""
        }
    }

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
    
    //MARK: helpers
    func updateSongInfo() {
        let player = MPMusicPlayerController()
        if let item = player.nowPlayingItem {
            artistLabel.setText(item.albumArtist)
            songLabel.setText(item.title)
        }
        else if !Utils.inSimulator {
            artistLabel.setText("")
            songLabel.setText("")
        }
        updatePlayState()
    }
    
    func updatePlayState() {
        let player = MPMusicPlayerController()
        switch (player.playbackState) {
            case (.Playing) : playButton.setBackgroundImageNamed("note")
            default: playButton.setBackgroundImageNamed("pause")
        }
    }
    
    //MARK: WKInterfaceController methods
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        updateSongInfo()
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }
    
    func playMix(refreshList : Bool = false) {
        playList(WK_MIX_PLAYLIST, refreshList:refreshList)
    }
    
    func playLiked(refreshList : Bool = false) {
        playList(WK_LIKED_PLAYLIST, refreshList:refreshList)
    }
    
    func playList(listName : String, refreshList : Bool) {
        //prevent going to phone for now because the startup takes too long and times out
        if 1==2 && refreshList {
            refreshListFromPhone(listName)
        }
        else {
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
    }
    
    func playArtist() {
        let player = MPMusicPlayerController()
        let defaults = Utils.AppGroupDefaults
        
        if let artist = player.nowPlayingItem?.albumArtist {
            if let ids = defaults.objectForKey(artist) as? [String] {
                var songs = ITunesUtils.getSongsFrom(ids)
                if songs.count > 0 {
                    songs.shuffle()
                    MusicPlayer.queuePlaylist(songs, songToStart: nil, startNow: true)
                    updateSongInfo()
                }
            }
        }
    }
    
    func refreshListFromPhone(listName : String) {
        let request = ["action":listName]
        WKInterfaceController.openParentApplication(request) { reply, error in
            println("User Info: \(reply)")
            println("Error: \(error)")
            if error == nil {
                self.playList(listName, refreshList: false)
            }
        }
    }
}
