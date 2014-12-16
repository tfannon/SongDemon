//
//  SearchAlbumController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 11/23/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import MediaPlayer

class SearchAlbumController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var lblArtist: UILabel!

    
    var currentSong : MPMediaItem?
    var previousArtist : String! = nil
    var songsByAlbum : [[MPMediaItem]] = []
    var manuallySelectedArtist = false
        
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        //if no image exists dont screw up image
        //playingSongImage = playingSongImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.tableView.backgroundColor = UIColor.blackColor()
        //empty cells wont create lines
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if reloadCheck() {
            let indexPath = getIndexPathForCurrentSong()
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
        }
    }
    
    func getIndexPathForCurrentSong() -> NSIndexPath {
        let albums : [String] = songsByAlbum.map { album in return album[0].albumTitle  }
        let section = albums.find { $0 == self.currentSong!.albumTitle }!
        let row = songsByAlbum[section].find {  $0.title == self.currentSong!.title }!
        let indexPath = NSIndexPath(forRow: row, inSection: section)
        return indexPath
    }
    
    func reloadCheck() -> Bool {
        println ("reload check")
        if let currentSong = MusicPlayer.currentSong {
            //the artist has changed.  need to reload
            if previousArtist == nil || currentSong.albumArtist! != previousArtist! {
                let artist = currentSong.albumArtist!
                selectArtist(artist)
                return true
            }
            //otherwise nothing changed.  just
        }
            //no current song playing, bounce back to artist picker
        else {
            self.tabBarController!.selectedIndex = 0
        }
        return false
    }

    func selectArtist(artist : String, manuallySelectedArtist : Bool = false, forceReload : Bool = false) {
        self.lblArtist.text = artist
        self.songsByAlbum = LibraryManager.getArtistSongsWithoutSettingPlaylist(artist).0
        self.tableView.reloadData()
        self.previousArtist = artist
        if forceReload || manuallySelectedArtist {
            self.tableView.reloadData()
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return songsByAlbum.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songsByAlbum[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchAlbumTrackCell") as SearchAlbumTrackCell
        let song = songsByAlbum[indexPath.section][indexPath.row]
        cell.lblTitle.text = song.title
        cell.lblTrackNumber.text = "\(song.albumTrackNumber)."
        if indexPath == getIndexPathForCurrentSong() {
            cell.imgPlaying.setAnimatableImage(named: "animated_music_bars.gif")
            if MusicPlayer.isPlaying {
                cell.imgPlaying.startAnimatingGIF()
            }
            cell.imgPlaying.hidden = false
        } else {
            cell.imgPlaying.stopAnimatingGIF()
            cell.imgPlaying.hidden = true
        }
        return cell
    }
    
    //header
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var cell = tableView.dequeueReusableCellWithIdentifier("SearchAlbumTitleCell") as SearchAlbumTitleCell
        let album = songsByAlbum[section]
        cell.lblTitle.text = album[0].albumTitle
        cell.imgAlbum.image = album[0].getArtworkWithSize(cell.imgAlbum.frame.size)
        cell.lblInfo.text = album[0].year
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 35.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70.0
    }
}
