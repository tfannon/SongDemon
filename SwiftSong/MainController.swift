//
//  MainController.swift
//  SwiftSong
//
//  Created by Tommy Fannon on 6/18/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import MediaPlayer
import AVFoundation

class MainController: UIViewController, LibraryScanListener {

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
    @IBOutlet var btnLike: UIButton!
    @IBOutlet var btnDislike: UIButton!
    @IBOutlet var btnShare: UIButton!
    @IBOutlet var btnAddToQueue: UIButton!

    @IBAction func playlistTapped(AnyObject) { handlePlaylistTapped() }
    @IBAction func searchTapped(sender: AnyObject) { handleSearchTapped() }
    @IBAction func likeTapped(sender: AnyObject) { handleLikeTapped()}
    @IBAction func dislikeTapped(sender: AnyObject) { handleDislikeTapped() }
    @IBAction func shareTapped(sender: AnyObject) { handleShareTapped() }
    @IBAction func addToQueueTapped(sender: AnyObject) { handleAddToQueueTapped() }
   
    //MARK: instance variables
    var playButtonsVisible = false
    //this is used so the event handlers can decide if they need to do something because song changed
    var lastSongHandledByViewController : MPMediaItem?
    //var audioPlayer : AVAudioPlayer! = nil


    //MARK: controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupGestures()
        setupNotifications()
        self.setNeedsStatusBarAppearanceUpdate()
        if Utils.inSimulator {
            //do anything specific to get simulator working
        }
        //search cannot be enabled until the library scan is complete
        //playAudio()
        btnSearch.hidden = true
    }
    
    override func shouldAutorotate() -> Bool {
        return false
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
    }
    
    func setupGestures() {
        //tapping on the artwork pauses/plays
        viewArtwork.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleImageTapped"))
        
        //swiping up brings up playlist picker
        var swipeUp = UISwipeGestureRecognizer(target: self, action: "handlePlaylistTapped")
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
        
        //swiping down brings up search
        var swipeDown = UISwipeGestureRecognizer(target: self, action: "handleSearchTapped")
        swipeDown.direction = .Down
        view.addGestureRecognizer(swipeDown)
    }
    
    func setupSimulator() {
        updateLyricState()
        updateVideoState()
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
    
    /*
    func playAudio() {
        var error : NSError?
        //let fileURL:NSURL = NSBundle.mainBundle().URLForResource("buzz", withExtension: "mp3")!
        let fileURL:NSURL = NSBundle.mainBundle().URLForResource("1sec", withExtension: "mp3")!
        self.audioPlayer = AVAudioPlayer(contentsOfURL: fileURL, error: &error)
        audioPlayer.numberOfLoops = -1
        AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryAmbient, error:nil)
        AVAudioSession.sharedInstance().setActive(true, error: nil)
        audioPlayer.prepareToPlay()
        audioPlayer.play()
    }
    */
    

    func handlePrevTapped() {
        MusicPlayer.reverse()
    }
    
    func handlePlayTapped() {
        MusicPlayer.playPressed()
        updatePlayButton()
    }
    
    func handleNextTapped() {
        MusicPlayer.forward()
    }
    
    func handleShareTapped() {
        if Utils.inSimulator {
            
            let artworkUrl = "http://ecx.images-amazon.com/images/I/511pkBGfKcL._SL500_AA280_PJStripe-Robin,TopLeft,0,0_.jpg"
            
            let videoUrl = "https://www.youtube.com/watch?v=j3G0bRUDR6I"
            FacebookUtils.post("Goatwhore", title: "In Deathless Tradition", artworkUrl:artworkUrl, videoUrl: videoUrl, callback: { status in
                    self.lblStatus.text = status
                })
            return
        }
        if let currentItem = MusicPlayer.currentSong {
            
            let videoUrl = RootController.getPlayVideoController().currentVideoUrl
            let artworkUrl = RootController.getPlayVideoController().currentArtworkUrl
            
            FacebookUtils.post(currentItem.artist ,title: currentItem.title, artworkUrl:artworkUrl, videoUrl: videoUrl, callback: { status in
                //set a status
            })
        }
    }
   
    func handleSearchTapped() {
        var vc = self.storyboard!.instantiateViewControllerWithIdentifier("SearchController") as SearchController
        //if something is in the player, use this to pre-select the artist in the searchController
        vc.currentlyPlayingArtist = MusicPlayer.currentSong != nil ? MusicPlayer.currentSong.albumArtist : nil
        presentViewController(vc, animated: false, completion: nil)
    }
    
    func handleAddToQueueTapped() {
        
        let isSong = MusicPlayer.currentSong != nil
        let currentSong = MusicPlayer.currentSong;

        var alert = UIAlertController(title: "Choose what to put in your personal queue to listen to later", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)

        if isSong {
            alert.addAction(UIAlertAction(title: "This song", style: .Default, handler: { action in
                LibraryManager.addToQueued(currentSong)
                self.displayFadingStatus ("Song added to Play later queue")
            }))
            
            alert.addAction(UIAlertAction(title: "Remove this song", style: .Destructive, handler: { action in
                LibraryManager.removeFromQueued(currentSong)
                self.displayFadingStatus ("Song removed from queue")
            }))

            alert.addAction(UIAlertAction(title: "Songs from this album", style: .Default, handler: { action in
                var songs = LibraryManager.getAlbumSongsWithoutSettingPlaylist(currentSong);
                LibraryManager.addToQueued(songs)
                self.displayFadingStatus ("Album added to Play Later queue")
            }))
       
            
            alert.addAction(UIAlertAction(title: "Remove this album", style: .Destructive, handler: { action in
                var songs = LibraryManager.getAlbumSongsWithoutSettingPlaylist(currentSong);
                LibraryManager.removeFromQueued(songs)
                self.displayFadingStatus ("Album removed from queue")
            }))
        }
            
        alert.addAction(UIAlertAction(title: "Clear my queue", style: .Destructive, handler: { action in
                LibraryManager.clearQueued()
                self.displayFadingStatus ("Play later queue was cleared")
        }))
           
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
        }))
            
        self.presentViewController(alert, animated: true, completion: {})
    }
    
    
    func handlePlaylistTapped() {
        var alert = UIAlertController(title: "Choose songs to play", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        
        alert.addAction(UIAlertAction(title: "Recently added", style: .Default, handler: { action in
            var songs = LibraryManager.getRecentlyAdded()
            self.postPlaylistSelection(songs: songs)
        }))
        
        alert.addAction(UIAlertAction(title: "My queue", style: .Default, handler: { action in
            var songs = LibraryManager.getQueuedSongs()
            self.postPlaylistSelection(songs: songs)
        }))
        
        alert.addAction(UIAlertAction(title: "Random mix", style: .Default, handler: { action in
            var songs = LibraryManager.getMixOfSongs()
            self.postPlaylistSelection(songs: songs)
        }))
        
        alert.addAction(UIAlertAction(title: "Liked", style: .Default, handler: {action in
            var songs = LibraryManager.getLikedSongs()
            self.postPlaylistSelection(songs: songs)
        }))
        
        alert.addAction(UIAlertAction(title: "New", style: .Default, handler: { action in
            var songs = LibraryManager.getNewSongs()
            self.postPlaylistSelection(songs: songs)
        }))
        
        if let currentSong = MusicPlayer.currentSong {
            var message = "Songs from this artist"
            alert.addAction(UIAlertAction(title: message, style: .Default, handler: { action in
                var songs = LibraryManager.getArtistSongs(currentSong);
                self.postPlaylistSelection(songs: songs, message: "Songs from \(currentSong.albumArtist) are queued", queue:true)
            }))
            
            message = "Songs from this album"
            alert.addAction(UIAlertAction(title: message, style: .Default, handler: { action in
                var songs = LibraryManager.getAlbumSongs(currentSong);
                self.postPlaylistSelection(songs: songs, message:"Songs from \(currentSong.albumTitle) are queued", queue:true)
            }))
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            self.unhideImageAndBlankStatus()
        }))
        //no matter what option is chosen switch the window back to main
        self.presentViewController(alert, animated: true, completion: {
            self.displayFadingStatus("Generating playlist")
            //self.waiting()
        })
    }
    
    // if the current song is among the songs in the upcoming playlist
    // add the songs to the queue without starting a playlist
    func postPlaylistSelection(songs: [MPMediaItem]=[MPMediaItem](), message : String? = nil, queue: Bool = false) {
        if songs.count > 0 {
            if queue {
                let indexOfCurrentSong = find(songs, MusicPlayer.currentSong)!
                var nextSong : MPMediaItem?
                //this keeps the position of the song immediately following current song
                //so the next itemplayingdidchange notification will trigger the queue to
                //start and use the correct position
                if indexOfCurrentSong + 1 < songs.count {
                    nextSong = songs[indexOfCurrentSong + 1]
                }
                MusicPlayer.queuePlaylist(songs, songToStart: nextSong)
            }
            else {
                MusicPlayer.play(songs)
            }
        }
        else {
            UIHelpers.messageBox(message:"There are no songs in the playlist")
        }
        if message != nil {
            displayFadingStatus(message!)
        }
        unhideImageAndBlankStatus()
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
    
    func handleDislikeTapped() {
        LibraryManager.addToDisliked(MusicPlayer.currentSong)
        MusicPlayer.forward()
        //reset the liked state
        changeLikeState(.Disliked)
    }

    
    //mark helpers
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
    
    /* we will animate the transition of the background image when buttons fade in and out */
    func fadePlayButtonsIn() {
        NSTimer.scheduledTimerWithTimeInterval(0.1, target:self, selector:"fadeOutImage", userInfo:nil, repeats:false);
        viewPlayOverlay.alpha = 0.7
        playButtonsVisible = true
    }
    
    func fadePlayButtonsOut() {
        NSTimer.scheduledTimerWithTimeInterval(0.1, target:self, selector:"fadeInImage", userInfo:nil, repeats:false);
        viewPlayOverlay.alpha = 0.2  //alpha = 0.0 dont receive touch events
        playButtonsVisible = false
    }
    
    func fadeOutImage() {
        UIView.animateWithDuration(0.25, animations: { self.imgSong.alpha = 0.2 })
    }
    
    func fadeInImage() {
        UIView.animateWithDuration(0.25, animations: { self.imgSong.alpha = 1.0 })
    }
    
    
    func displayFadingStatus(message : String) {
        self.lblStatus.text = message
    }
    
    func hideImage() {
        self.imgSong.hidden = true
    }
    
    func unhideImageAndBlankStatus() {
        imgSong.hidden = false
        lblStatus.text = ""
    }
    
    func transitionSongImage(toImage : UIImage?) {
        if toImage != nil {
            UIView.transitionWithView(imgSong, duration: 1, options: .TransitionCrossDissolve, animations: { self.imgSong.image = toImage }, completion: nil)
        } else {
            self.imgSong.image = nil
        }
    }


 
    //MARK: notifications
    func setupNotifications() {
        let center = NSNotificationCenter.defaultCenter();
        
        center.addObserverForName(UIApplicationDidBecomeActiveNotification,
            object: nil, queue: nil, usingBlock: { _ in
                println("UIApplicationDidBecomeActive")
                self.updateSongInfo()
                self.updatePlayState()
        })
       
        center.addObserverForName(MPMusicPlayerControllerNowPlayingItemDidChangeNotification,
            object: nil, queue:nil) { _ in
                //println("NowPlayingItemDidChange")
                if MusicPlayer.currentSong != nil {
                    println("Song changed to \(MusicPlayer.currentSong.songInfo)")
                }
                MusicPlayer.playSongsInQueue()
                self.updateSongInfo()
                self.updatePlayState()
                self.updateLyricState()
                self.updateVideoState()
                self.lastSongHandledByViewController = MusicPlayer.currentSong
        }
        
        center.addObserverForName(MPMusicPlayerControllerPlaybackStateDidChangeNotification,
            object: nil, queue:nil) { _ in
                println ("PlaybackStateDidChange")
                self.updatePlayState()
        }
    }
    
    //MARK: notification handlers
    func updateSongInfo() {
        lblStatus.text = ""
        
        if Utils.inSimulator {
            return
        }
        
        let item = MusicPlayer.currentSong
        if item == self.lastSongHandledByViewController {
            println("updateSongInfo called but song has not changed")
            return
        }
            
        if item != nil {
            lblArtist.text = "\(item.albumArtist) - \(item.albumTitle)"
            lblSong.text = item.title
            //if it was a liked item, change the state
            var state = LibraryManager.isLiked(item) ?
                LikeState.Liked : LikeState.None
            changeLikeState(state)
    
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

    
    func updatePlayState() {
        if MusicPlayer.currentSong == self.lastSongHandledByViewController {
            return
        }
        updatePlayButton()
    }
    
    func updatePlayButton() {
        var image: UIImage;
        if MusicPlayer.isPlaying {
            image = UIImage(named:"pause.png")!;
            fadePlayButtonsOut()
            lblStatus.text = ""
        }
        else {
            image = UIImage(named:"play-75.png")!;
            fadePlayButtonsIn()
            lblStatus.text = "Paused"
        }
        btnPlay.setImage(image, forState: UIControlState.Normal)
    }
    
    func updateLyricState() {
        if MusicPlayer.currentSong == self.lastSongHandledByViewController {
            return
        }
        Async.background {
            Lyrics.fetchUrlFor(MusicPlayer.currentSong)
        }
    }
    
    func updateVideoState() {
        if MusicPlayer.currentSong == self.lastSongHandledByViewController {
            return
        }
        Async.background {
            Videos.fetchVideosFor(MusicPlayer.currentSong)
        }
    }
    
    //MARK: Song scrubber
    var timer = NSTimer()
    
    func handleScrubberChanged() {
        if let currentSong = MusicPlayer.currentSong {
            if scrubber.timeValue.totalSeconds < currentSong.playTime.totalSeconds {
                //println("scrubber changed: \(scrubber.value)")
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

    //MARK: LibraryScanListener
    func libraryScanComplete() {
        Async.main {
            self.btnSearch.hidden = false
            self.displayFadingStatus("\(LibraryManager.songCount) songs in library")
        }
    }
}
