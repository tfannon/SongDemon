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
    
    func updateSongInfo() {
        let player = MPMusicPlayerController()
        if let item = player.nowPlayingItem {
            artistLabel.setText(item.albumArtist)
            songLabel.setText(item.title)
        }
        else {
            artistLabel.setText("")
            songLabel.setText("")
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
