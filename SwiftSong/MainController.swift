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

    //MARK: outlets
    @IBOutlet var viewArtwork: UIView!
    @IBOutlet var imgSong: UIImageView!

    @IBOutlet var viewIndicators: UIView!
    @IBOutlet var btnShare: UIButton!
    @IBOutlet var btnPlaylist: UIButton!
   
    @IBOutlet weak var lblTimeElapsed: UILabel!
    @IBOutlet weak var lblTimeRemaining: UILabel!
    @IBOutlet var scrubber: UISlider!
    @IBAction func scrubberChanged(sender: AnyObject) { handleScrubberChanged() }
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet var viewSongInfo: UIView!
    @IBOutlet var lblArtist: UILabel!
    @IBOutlet var lblSong: UILabel!

    
    @IBOutlet var viewPlayButtons: UIView!
    @IBOutlet var btnDislike: UIButton!
    @IBOutlet var btnPrev: UIButton!
    @IBOutlet var btnPlay: UIButton!
    @IBOutlet var btnNext: UIButton!
    @IBOutlet var btnLike: UIButton!
    
    @IBOutlet var viewScrubber: UIView!
    @IBOutlet var btnSearch: UIButton!


    //MARK: actions
    @IBAction func dislikeTapped(sender: AnyObject) { handleDislikeTapped()}
    @IBAction func likeTapped(sender: AnyObject) { handleLikeTapped()}
    @IBAction func playTapped(AnyObject) { MusicPlayer.playPressed() }
    @IBAction func prevTapped(AnyObject) { MusicPlayer.reverse() }
    @IBAction func nextTapped(AnyObject) { MusicPlayer.forward() }
    @IBAction func playlistTapped(AnyObject) { handlePlaylistTapped() }

    @IBAction func searchTapped(sender: AnyObject) { handleSearchTapped() }
    @IBAction func shuffleTapped(sender: AnyObject) { handleShuffleTapped()}

    //MARK: instance variables
   

    //MARK: controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupNotifications()
        setupSimulator()
    }
  
    //MARK: setup
    func setupAppearance() {
        //self.view.backgroundColor = UIColor.blackColor()
       
        imgSong.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleImageTapped"))

        //swiping up allows user to select playlist
        var swipeUp = UISwipeGestureRecognizer(target: self, action: "handlePlaylistTapped")
        swipeUp.direction = .Up
        imgSong.addGestureRecognizer(swipeUp)
    }
    
    func setupSimulator() {
        updateLyricState()
    }
    
   
    //MARK: Action handlers
    func handleImageTapped() {
    }
    
    func handleSearchTapped() {
        waiting()
        let mediaPicker = MPMediaPickerController(mediaTypes: .Music)
        mediaPicker.delegate = self
        mediaPicker.allowsPickingMultipleItems = true
        presentViewController(mediaPicker, animated: true, completion: {
            self.doneWaiting() })
    }
    
    func handleShuffleTapped() {
       
    }
    
    func waiting() {
        self.activityIndicator.startAnimating()
        self.imgSong.hidden = true
        //self.imgSong.image = nil
    }
    
    func doneWaiting() {
        activityIndicator.stopAnimating()
        imgSong.hidden = false
    }
    
    func handlePlaylistTapped() {
        var alert = UIAlertController(title: "Choose songs to play", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
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
        
        if let currentSong = MusicPlayer.currentSong() {
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
        if LibraryManager.isLiked(MusicPlayer.currentSong()) {
            LibraryManager.removeFromLiked(MusicPlayer.currentSong())
            changeLikeState(.None)
        } else {
            LibraryManager.addToLiked(MusicPlayer.currentSong())
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
        LibraryManager.addToDisliked(MusicPlayer.currentSong())
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
                if MusicPlayer.currentSong() != nil {
                    println("Song changed to \(LibraryManager.getSongInfo(MusicPlayer.currentSong()))")
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
        if Utils.inSimulator() {
            return
        }
        if let item = MusicPlayer.currentSong() {
            lblArtist.text = "\(item.albumArtist) - \(item.albumTitle)"
            lblSong.text = item.title
            //if it was a liked item, change the state
            var state = LibraryManager.isLiked(item) ?
                LikeState.Liked : LikeState.None
            changeLikeState(state)
            imgSong.image = (item.artwork != nil) ?
                item.artwork.imageWithSize(imgSong.frame.size) : nil
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
    }
    
    func updatePlayState() {
        var image: UIImage;
        if MusicPlayer.isPlaying() {
            image = UIImage(named:"pause.png");
        }
        else {
            image = UIImage(named:"play.png");
        }
        btnPlay.setImage(image, forState: UIControlState.Normal)
    }
    
    func updateLyricState() {
        Lyrics.fetchUrlFor(MusicPlayer.currentSong())
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
        if let currentSong = MusicPlayer.currentSong() {
            if scrubber.timeValue.totalSeconds < currentSong.playTime.totalSeconds {
                println("scrubber changed: \(scrubber.value)")
                MusicPlayer.playbackTime = scrubber.timeValue.totalSeconds
                startPlaybackTimer()
            } else {
            }
        }
    }
    
    func startPlaybackTimer() {
        println("scrubber timer started")
        timer.invalidate()
        timer = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector:"updateScrubber", userInfo:nil, repeats:true)
    }
    
    func updateScrubber() {
        let cur : Int = MusicPlayer.playbackTime;
        let tot : Int = Int(MusicPlayer.currentSong().playbackDuration)
        let rem : Int = tot - cur
        //println("Total:\(tot)  Current:\(cur)  Remaining:\(rem)")
        scrubber.value = Float(cur)
        lblTimeRemaining.text = String(rem)
        lblTimeElapsed.text = String(cur)
    }
}
