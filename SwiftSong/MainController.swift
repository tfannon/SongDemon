//
//  MainController.swift
//  SwiftSong
//
//  Created by Tommy Fannon on 6/18/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import MediaPlayer

class MainController: UIViewController {

    //MARK: outlets
    @IBOutlet var viewArtwork: UIView!
    @IBOutlet var imgSong: UIImageView!
    @IBOutlet var webView: UIWebView!

    @IBOutlet var viewIndicators: UIView!
    @IBOutlet var btnYouTube: UIButton!
    @IBOutlet var btnLyrics: UIButton!
    @IBOutlet var btnShare: UIButton!

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
    @IBOutlet var scrubber: UISlider!

    //MARK: actions
    @IBAction func lyricTapped(AnyObject) { handleLyricsTapped() }

    @IBAction func dislikeTapped(sender: AnyObject) { handleDislikeTapped()}
    @IBAction func likeTapped(sender: AnyObject) { handleLikeTapped()}
    @IBAction func playTapped(AnyObject) { MusicPlayer.playPressed() }
    @IBAction func prevTapped(AnyObject) { MusicPlayer.reverse() }
    @IBAction func nextTapped(AnyObject) { MusicPlayer.forward() }

    //MARK: instance variables
    let inSimulator = Utils.inSimulator()
    var lyricsAvailable = false
    var lyricState = LyricState.NotAvailable

    //MARK: controller methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        setupNotifications()
        setupSimulator()
    }

    //MARK: setup
    func setupAppearance() {
        webView.hidden = true
        imgSong.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "handleLyricsTapped"))
        //not working
        //webView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "webviewTap"))
    }
    
    func setupSimulator() {
        updateLyricState()
    }
    
    //MARK: button handlers
    func handleLyricsTapped() {
        switch lyricState {
            //case .NotAvailable://
        case .Available:
            lyricState = .Displayed
            imgSong.hidden = true
            webView.hidden = false
        case .Displayed:
            lyricState = .Available
            imgSong.hidden = false
            webView.hidden = true
        default:""
        }
    }
    
    func handleLikeTapped() {
        //if its already liked this will reset it and unset the selected image
        if LibraryManager.isLiked(MusicPlayer.currentSong()) {
            LibraryManager.removeFromLiked(MusicPlayer.currentSong())
            btnLike.setImage(UIImage(named: "1116-slayer-hand.png"), forState: UIControlState.Normal)
        } else {
            LibraryManager.addToLiked(MusicPlayer.currentSong())
            btnLike.setImage(UIImage(named: "1116-slayer-hand-selected.png"), forState: UIControlState.Normal)
            let v = UIAlertView()
            v.title = "Title"
            v.message = "Song added"
            v.addButtonWithTitle("Ok")
            v.show()
        }
    }
    
    func handleDislikeTapped() {
        LibraryManager.addToDisliked(MusicPlayer.currentSong())
        //reset the liked state
        btnLike.setImage(UIImage(named: "1116-slayer-hand.png"), forState: UIControlState.Normal)
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
                    println("Song changed to \(MusicPlayer.currentSong().title)")
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
        var item = MusicPlayer.currentSong()
        if item != nil {
            lblArtist.text = "\(item.albumArtist) - \(item.albumTitle)"
            lblSong.text = item.title
            //if it was a liked item, change the state
            var image = LibraryManager.isLiked(item) ?
                "1116-slayer-hand-selected.png" : "1116-slayer-hand.png"
            btnLike.setImage(UIImage(named: image), forState: UIControlState.Normal)
            //flip back to artwork
            lyricState = .Available
            imgSong.hidden = false
            webView.hidden = true
            if (item.artwork != nil) {
                imgSong.image = item.artwork.imageWithSize(imgSong.frame.size)
                return;
            } else {
                imgSong.image = nil
                return;
            }
        }
        //if we got here there was no song
        else {
            imgSong.image = nil
            lblArtist.text = "[No item in queue]"
            lblSong.text = ""
        }
    }
    
    func updatePlayState() {
        var image: UIImage;
        if MusicPlayer.isPlaying() {
            println("playing")
            image = UIImage(named:"1242-pause.png");
        }
        else {
            println("paused")
            image = UIImage(named:"1241-play.png");
        }
        btnPlay.setImage(image, forState: UIControlState.Normal)
    }
    
    func updateLyricState() {
        let url = Utils.inSimulator() ? Lyrics.getUrlFor(nil) :
            Lyrics.getUrlFor(MusicPlayer.currentSong())
        if (url) {
            webView.loadRequest(NSURLRequest(URL: url))
            lyricState = .Available
            btnLyrics.tintColor = UIColor.whiteColor()
        } else {
            lyricState = .NotAvailable
            self.btnLyrics.tintColor = UIColor.lightGrayColor()
        }
    }
}
