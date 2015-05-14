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
    
    @IBOutlet weak var artworkImage: WKInterfaceImage!
    
    @IBAction func favoritesTapped() {
        let request = ["action":"playFavorites"]
        WKInterfaceController.openParentApplication(request) { (reply,error) in
            println(reply)
            if error == nil {
                if let replyDict = reply as? [String:String] {
                    self.updateSongInfo()
                }
            }
        }
    }
    
    func updateSongInfo() {
        let player = MPMusicPlayerController()
        if let item = player.nowPlayingItem {
            artistLabel.setText(item.albumArtist)
            songLabel.setText(item.title)
            /*put the image tio this while we fetch
            self.artworkImage.setImageNamed("black-red-note")
            Async.background {
                self.artworkImage.setImage(item.artwork.imageWithSize(CGSize(width: 40, height: 40)))
            }
            */
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
    
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
        updateSongInfo()
        
        /*
        let request = ["Action":"GetSongInfo"]
        WKInterfaceController.openParentApplication(request) { (reply,error) in
            println(reply)
            if error == nil {
                if let replyDict = reply as? [String:String] {
                    self.artistLabel.setText(replyDict["artist"])
                    self.songLabel.setText(replyDict["song"])
                    switch (replyDict["playState"]!) {
                    case ("paused") : ""
                    case ("playing") : ""
                    default:""
                    }
                }
                
            }
        }
        */
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
