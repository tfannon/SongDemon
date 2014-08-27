//
//  MainController.swift
//  SwiftSong
//
//  Created by Tommy Fannon on 6/18/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import MediaPlayer

class MainController: UIViewController, MPMediaPickerControllerDelegate {

    //MARK: outlets and actions
    @IBOutlet var viewMain: UIView!
    @IBOutlet var viewArtwork: UIView!
    @IBOutlet var imgSong: UIImageView!
    @IBOutlet var lblStatus: UILabel!

    @IBOutlet var viewPlayOverlay: UIView!
    @IBOutlet var btnPrev: UIButton!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var btnNext: UIButton!
    @IBAction func prevTapped(AnyObject) { handlePrevTapped() }
    @IBAction func playTapped(AnyObject) { handlePlayTapped() }
    @IBAction func nextTapped(AnyObject) { handleNextTapped() }

    @IBOutlet var viewScrubber: UIView!
    @IBOutlet var scrubber: UISlider!
    @IBAction func scrubberChanged(sender: AnyObject) { handleScrubberChanged() }
    
    @IBOutlet var viewSongInfo: UIView!
    @IBOutlet var lblArtist: UILabel!
    @IBOutlet var lblSong: UILabel!
    
    @IBOutlet var viewOtherButtons: UIView!
    @IBOutlet var btnPlaylist: UIButton!
    @IBOutlet var btnSearch: UIButton!
    @IBOutlet var btnRecord: UIButton!
    @IBOutlet var btnLike: UIButton!
    @IBOutlet var btnDislike: UIButton!

    @IBAction func playlistTapped(AnyObject) { handlePlaylistTapped() }
    @IBAction func searchTapped(sender: AnyObject) { handleSearchTapped() }
    @IBAction func recordTapped(sender: UIButton) { handleRecordTapped() }
    @IBAction func likeTapped(sender: AnyObject) { handleLikeTapped()}
    @IBAction func dislikeTapped(sender: AnyObject) { handleDislikeTapped()}

   
    //MARK: instance variables
    var recording = false
    var startRecordTime = 0
    var playButtonsVisible = false

    //MARK: controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupNotifications()
        setupSimulator()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
  
    //MARK: setup
    func setupAppearance() {

        lblStatus.text = ""
       
        //these allow the large system images to scale
        btnPlay.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill
        btnPlay.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill
        btnPrev.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill
        btnPrev.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill
        btnNext.contentHorizontalAlignment = UIControlContentHorizontalAlignment.Fill
        btnNext.contentVerticalAlignment = UIControlContentVerticalAlignment.Fill
        
        viewArtwork.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleImageTapped"))

        //swiping up allows user to select playlist
        var swipeUp = UISwipeGestureRecognizer(target: self, action: "handlePlaylistTapped")
        swipeUp.direction = .Up
        viewArtwork.addGestureRecognizer(swipeUp)
       
        /*
        var gr = UILongPressGestureRecognizer(target: self, action: "handleScrubberLongPress:")
        gr.delaysTouchesEnded = true
        scrubber.addGestureRecognizer(gr)
        */
    }
    
    /*
    func handleScrubberLongPress(gr: UILongPressGestureRecognizer) {
        if gr.state == UIGestureRecognizerState.Ended {
            println("Long press detected")
        }
    }
    */
    
    func setupSimulator() {
        updateLyricState()
    }
    
  
    //MARK: Action handlers
    func handleImageTapped() {
        //println("image tapped")
        if playButtonsVisible {
            fadePlayButtonsOut()
        }
        else {
            fadePlayButtonsIn()
        }
        /* this code can dissolve between two images
            //let toImage = flip ? UIImage(named:"sample-album-art.jpg") : UIImage(named:"sample-album-art2.jpg")
            //UIView.transitionWithView(imgSong, duration: 1, options: .TransitionCrossDissolve, animations: { self.imgSong.image = toImage }, completion: nil)
        */
    }

    /* we will animate the transition of the background image when buttons fade in and out */
    func fadePlayButtonsIn() {
        NSTimer.scheduledTimerWithTimeInterval(0.1, target:self, selector:"fadeOutImage", userInfo:nil, repeats:false);
        viewPlayOverlay.alpha = 1.0
        playButtonsVisible = true
    }
    
    func fadeOutImage() {
        UIView.animateWithDuration(0.25, animations: { self.imgSong.alpha = 0.2 })
    }
    
    func fadePlayButtonsOut() {
        NSTimer.scheduledTimerWithTimeInterval(0.1, target:self, selector:"fadeInImage", userInfo:nil, repeats:false);
        viewPlayOverlay.alpha = 0.2  //alpha = 0.0 dont receive touch events
        playButtonsVisible = false
    }
    
    func fadeInImage() {
        UIView.animateWithDuration(0.25, animations: { self.imgSong.alpha = 1.0 })
    }

    
    func handlePrevTapped() {
        MusicPlayer.reverse()
    }
    
    func handlePlayTapped() {
        MusicPlayer.playPressed()
    }
    
    func handleNextTapped() {
        MusicPlayer.forward()
    }
    
    func handleSearchTapped() {
        lblStatus.textColor = UIColor.orangeColor()
        lblStatus.text = "Querying iTunes"
        waiting()
        let mediaPicker = MPMediaPickerController(mediaTypes: .Music)
        mediaPicker.delegate = self
        mediaPicker.allowsPickingMultipleItems = true
        presentViewController(mediaPicker, animated: true, completion: {
            self.doneWaiting() })
    }
    
    func handleRecordTapped() {
        if MusicPlayer.currentSong == nil && !Utils.inSimulator {
            return
        }
        var image : String
        var tintColor : UIColor = viewOtherButtons.tintColor
        if recording {
            lblStatus.text = ""
            lblStatus.textColor = UIColor.orangeColor()
            image = "1244-record.png"
            
        } else {
            lblStatus.text = "Recording Riff"
            lblStatus.textColor = UIColor.redColor()
            image = "1244-record-selected.png"
            tintColor = UIColor.redColor()
        }
        recording = !recording
        btnRecord.tintColor = tintColor
    }
    
    func waiting() {
        self.imgSong.hidden = true
    }
    
    func doneWaiting() {
        imgSong.hidden = false
        lblStatus.text = ""
    }
    
    func handlePlaylistTapped() {
        var alert = UIAlertController(title: "Choose songs to play", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)

        //destructive makes it show up in red
        alert.addAction(UIAlertAction(title: "Riff mode", style: .Destructive, handler: { action in
            var songs = LibraryManager.getMixOfSongs()
            self.postPlaylistSelection("Random mix is playing", songs: songs)
        }))

        alert.addAction(UIAlertAction(title: "Random mix", style: .Default, handler: { action in
            var songs = LibraryManager.getMixOfSongs()
            self.postPlaylistSelection("Random mix is playing", songs: songs)
        }))
        
        alert.addAction(UIAlertAction(title: "Liked", style: .Default, handler: {action in
            var songs = LibraryManager.getLikedSongs()
            self.postPlaylistSelection("Liked songs are playing", songs: songs)
        }))
        
        alert.addAction(UIAlertAction(title: "New", style: .Default, handler: { action in
            var songs = LibraryManager.getNewSongs()
            self.postPlaylistSelection("New songs are playing", songs: songs)
        }))
        
        if let currentSong = MusicPlayer.currentSong {
            //var message = "\(currentSong.albumArtist) songs"
            var message = "Songs from this artist"
            alert.addAction(UIAlertAction(title: message, style: .Default, handler: { action in
                var songs = LibraryManager.getArtistSongs(currentSong);
                self.postPlaylistSelection("Songs from \(currentSong.albumArtist) are playing", songs: songs)
            }))
            
            //let message = "Songs from \(currentSong.albumTitle)"
            message = "Songs from this album"
            alert.addAction(UIAlertAction(title: message, style: .Default, handler: { action in
                var songs = LibraryManager.getAlbumSongs(currentSong);
                self.postPlaylistSelection("Songs from \(currentSong.albumTitle) are playing", songs: songs)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            self.doneWaiting()
        }))
        //no matter what option is chosen switch the window back to main
        self.presentViewController(alert, animated: true, completion: {
            self.lblStatus.text = "Generating playlist"
            self.lblStatus.textColor = UIColor.orangeColor()
            self.waiting()
        })
    }
    
    func postPlaylistSelection(message : String, songs: [MPMediaItem]=[MPMediaItem]()) {
        if songs.count > 0 {
            MusicPlayer.play(songs)
        }
        if !message.isEmpty {
            ""//UIHelpers.messageBox(message)
        }
        doneWaiting()
    }
    
    func handleLikeTapped() {
        //if its already liked this will reset it and unset the selected image
        if LibraryManager.isLiked(MusicPlayer.currentSong) {
            LibraryManager.removeFromLiked(MusicPlayer.currentSong)
            changeLikeState(.None)
        } else {
            LibraryManager.addToLiked(MusicPlayer.currentSong)
            changeLikeState(.Liked)
        }
    }
    
    func changeLikeState(state : LikeState) {
        var image : String
        switch state {
        case (.Liked) :
            image = "777-thumbs-up-selected.png"
        case (.Disliked) :
            image = "777-thumbs-up.png"
        case (.None) :
            image = "777-thumbs-up.png"
        default: image = ""
        }
        if !image.isEmpty {
            btnLike.setImage(UIImage(named: image), forState: UIControlState.Normal)
        }
    }
    
    func handleDislikeTapped() {
        LibraryManager.addToDisliked(MusicPlayer.currentSong)
        MusicPlayer.forward()
        //reset the liked state
        changeLikeState(.Disliked)
    }
 
    //MARK: notifications
    func setupNotifications() {
        let center = NSNotificationCenter.defaultCenter();
        
        center.addObserverForName(UIApplicationDidBecomeActiveNotification,
            object: nil, queue: nil, usingBlock: { _ in
                self.updateSongInfo()
                self.updatePlayState()
        })
       
        center.addObserverForName(MPMusicPlayerControllerNowPlayingItemDidChangeNotification,
            object: nil, queue:nil) { _ in
                if MusicPlayer.currentSong != nil {
                    println("Song changed to \(MusicPlayer.currentSong.songInfo)")
                }
                self.updateSongInfo()
                self.updatePlayState()
                self.updateLyricState()
        }
        
        center.addObserverForName(MPMusicPlayerControllerPlaybackStateDidChangeNotification,
            object: nil, queue:nil) { _ in
                //println ("new playstate event")
                self.updatePlayState()
        }
    }
    
    //MARK: notification handlers
    func updateSongInfo() {
        recording = false
        lblStatus.text = ""
        
        if Utils.inSimulator {
            return
        }
        if let item = MusicPlayer.currentSong {
            lblArtist.text = "\(item.albumArtist) - \(item.albumTitle)"
            lblSong.text = item.title
            //if it was a liked item, change the state
            var state = LibraryManager.isLiked(item) ?
                LikeState.Liked : LikeState.None
            changeLikeState(state)
    
            /* old non-fancy way
            imgSong.image = (item.artwork != nil) ?
                item.artwork.imageWithSize(imgSong.frame.size) : nil
            */
            var newImage = (item.artwork != nil) ?
                item.artwork.imageWithSize(imgSong.frame.size) : nil
            transitionSongImage(newImage)
            
            LibraryManager.changePlaylistIndex(item)
            //set the scrubber initial values
            scrubber.minimumValue = 0
            scrubber.maximumValue = Float(item.playTime.totalSeconds)
            scrubber.value = 0
            startPlaybackTimer()
        }
        //if we got here there was no song
        else {
            imgSong.image = nil
            lblArtist.text = "[No playlist selected]"
            lblSong.text = ""
            self.timer.invalidate()
        }
        fadePlayButtonsOut()
    }

    func transitionSongImage(toImage : UIImage?) {
        if toImage != nil {
            UIView.transitionWithView(imgSong, duration: 1, options: .TransitionCrossDissolve, animations: { self.imgSong.image = toImage }, completion: nil)
        } else {
            self.imgSong.image = nil
        }
    }
    
    func updatePlayState() {
        var image: UIImage;
        if MusicPlayer.isPlaying() {
            image = UIImage(named:"pause.png");
            fadePlayButtonsOut()
            lblStatus.text = ""
        }
        else {
            image = UIImage(named:"play.png");
            fadePlayButtonsIn()
            lblStatus.text = "Paused"
            lblStatus.textColor = UIColor.orangeColor()
        }
        btnPlay.setImage(image, forState: UIControlState.Normal)
    }
    
    func updateLyricState() {
        Lyrics.fetchUrlFor(MusicPlayer.currentSong)
    }
    
    
    //MARK: MPMediaPickerControllerDelegate
    
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems  mediaItems:MPMediaItemCollection) -> Void
    {
        let items = mediaItems.items as [MPMediaItem]
        if items.count > 0 {
            LibraryManager.makePlaylistFromSongs(items)
            MusicPlayer.play(items, shuffle:false)
        }
        self.dismissViewControllerAnimated(true, completion: {
            UIHelpers.messageBox("Now playing your \(items.count) songs")
        });
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    //MARK: Song scrubber
    var timer = NSTimer()
    
    func handleScrubberChanged() {
        if let currentSong = MusicPlayer.currentSong {
            if scrubber.timeValue.totalSeconds < currentSong.playTime.totalSeconds {
                println("scrubber changed: \(scrubber.value)")
                MusicPlayer.playbackTime = scrubber.timeValue.totalSeconds
                startPlaybackTimer()
            } else {
            }
        }
    }
    
    func startPlaybackTimer() {
        //println("scrubber timer started")
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:"updateScrubber", userInfo:nil, repeats:true)
    }
    
    func updateScrubber() {
        let cur : Int = MusicPlayer.playbackTime;
        let tot : Int = Int(MusicPlayer.currentSong.playbackDuration)
        let rem : Int = tot - cur
        scrubber.value = Float(cur)
    }
}
