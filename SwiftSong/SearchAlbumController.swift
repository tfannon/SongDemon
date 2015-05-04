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

    var previousArtist : String! = nil
    var songsByAlbum : [[MPMediaItem]] = []
    var songsForPlaylist : [MPMediaItem] = []
    var selectedArtist : String! = nil
    var artistSelectedWithPicker : Bool = false
        
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
        //if the artist changed, reload the table
        artistCheck()
        //if there is a song being played and we came in from search button, scroll to playing song
        if !artistSelectedWithPicker && MusicPlayer.currentSong != nil {
            let indexPath = getIndexPathForCurrentSong()
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
        }
    }
    
    //MARK: helpers for getting song/artist
    func getIndexPathForCurrentSong() -> NSIndexPath {
        let albums : [String] = songsByAlbum.map { album in return album[0].albumTitle  }
        let section = albums.find { $0 == MusicPlayer.currentSong!.albumTitle }!
        let row = songsByAlbum[section].find {  $0.title == MusicPlayer.currentSong!.title }!
        let indexPath = NSIndexPath(forRow: row, inSection: section)
        return indexPath
    }
    
    //returns true if artist changed
    func artistCheck() {
        println ("artist check")
        if previousArtist == nil || selectedArtist != previousArtist {
            self.lblArtist.text = selectedArtist
            //this call returns a tuple,  the first value are the songs grouped by album. 
            //the second is a straight list of songs that can be sent to media player
            (self.songsByAlbum, self.songsForPlaylist) = LibraryManager.getArtistSongsWithoutSettingPlaylist(selectedArtist)
            self.tableView.reloadData()
            self.previousArtist = selectedArtist
        }
    }
    
    //MARK:  UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return songsByAlbum.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songsByAlbum[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchAlbumTrackCell") as! SearchAlbumTrackCell
        let song = songsByAlbum[indexPath.section][indexPath.row]
        cell.lblTitle.text = song.title
        cell.lblTrackNumber.text = "\(song.albumTrackNumber)."
        if !artistSelectedWithPicker && indexPath == getIndexPathForCurrentSong() {
            cell.imgPlaying.image = UIImage(named: "black-red-note-120.png")
            //cell.imgPlaying.setAnimatableImage(named: "animated_music_bars.gif")
            if MusicPlayer.isPlaying {
                //cell.imgPlaying.startAnimatingGIF()
            }
            cell.imgPlaying.hidden = false
        } else {
            //cell.imgPlaying.stopAnimatingGIF()
            cell.imgPlaying.hidden = true
        }
        return cell
    }
    
    //header
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var cell = tableView.dequeueReusableCellWithIdentifier("SearchAlbumTitleCell") as! SearchAlbumTitleCell
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
    
    //MARK: UITableViewDelegate
    //selection should put the all the artists songs in playlist, select that song, then return to title screen
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let song = songsByAlbum[indexPath.section][indexPath.row]
        LibraryManager.setPlaylistFromSearch(self.songsByAlbum, songsForQueue: self.songsForPlaylist, songToStart: song)
        self.dismissViewControllerAnimated(false, completion: nil)
    }
}
