//
//  PlaylistController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/4/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import MediaPlayer

class PlaylistController: UITableViewController {

    var sampleArtists = ["Goatwhore", "Goatwhore"]
    var sampleAlbums = ["Blood For The Master", "Constricting Rage of the Merciless"]
    var sampleSongs = ["In Deathless Tradition", "FBS"]
    var sampleImages = ["sample-album-art.jpg", "sample-album-art2.jpg"]
    
    var playingSongImage = UIImage(named: "1241-play-toolbar-selected.png")
    
    @IBOutlet var lblHeaderTitle: UILabel!
    @IBOutlet var viewHeader: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //if no image exists dont screw up image
        playingSongImage = playingSongImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.tableView.backgroundColor = UIColor.blackColor()
        //empty cells wont create lines
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        
        var view = self.tableView.tableHeaderView
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        redrawList()
    }
    
    /*
    override func scrollViewDidScroll(scrollView: UIScrollView!) {
        var rect = self.viewHeader.frame
        rect.origin.y = MIN(0, self.tableView.contentOffset.y)
        
        
    }*/
    
    func redrawList() {
        tableView.reloadData()
        var artistText : String = ""
        if LibraryManager.currentPlaylist.count == 0 {
            artistText = "No playlist selected"
        }
        else if LibraryManager.currentPlayMode != PlayMode.Album && LibraryManager.currentPlayMode == PlayMode.Artist {
            artistText = ""
        } else {
            artistText == LibraryManager.currentPlaylist[LibraryManager.currentPlaylistIndex].artist
        }
        lblHeaderTitle.text = artistText
        
        let index = LibraryManager.currentPlaylistIndex
        var indexPath : NSIndexPath
        if index == 0 {
            indexPath = NSIndexPath(forRow: 0, inSection: 0)
        } else {
            let section : Int = index / LibraryManager.groupedPlaylist.count
            let row = index % LibraryManager.groupedPlaylist.count
            indexPath = NSIndexPath(forRow: row, inSection: section)
        }
        tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
    }


    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return LibraryManager.groupedPlaylist.count
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if Utils.inSimulator {
            return sampleSongs.count
        }
        return LibraryManager.groupedPlaylist[section].count
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let mode = LibraryManager.currentPlayMode
        var identifier : String
        switch (mode) {
            case (.Artist), (.Album)  : identifier = "PlaylistAlbumSongCell"
            default: identifier = "PlaylistCell"
        }
        var cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) as UITableViewCell
        
        if Utils.inSimulator {
            let cell2 = cell as PlaylistCell
            cell2.lblTitle.text = sampleSongs[indexPath.row]
            cell2.lblArtistAlbum.text = "\(sampleArtists[indexPath.row]) - \(sampleAlbums[indexPath.row])"
            cell2.imgArtwork.image = UIImage(named: sampleImages[indexPath.row])
            cell2.imgStatus.tintColor = UIColor.lightGrayColor()
            cell2.imgStatus.image = playingSongImage
            return cell2
        }
        
        var song : MPMediaItem;
        var isPlaying : Bool
        switch (mode) {
        
        case (.Artist), (.Album):
            song = LibraryManager.groupedPlaylist[indexPath.section][indexPath.row]
            isPlaying = LibraryManager.currentPlaylistIndex == (indexPath.section * 1) + indexPath.row-1
            let cell2 = cell as PlaylistAlbumSongCell
            cell2.lblTrack.text = "\(song.albumTrackNumber)"
            cell2.lblTitle.text = song.title
            cell2.imgStatus.image = isPlaying ? playingSongImage : nil
        
        default:
            let cell2 = cell as PlaylistCell
            song = LibraryManager.currentPlaylist[indexPath.row]
            isPlaying = LibraryManager.currentPlaylistIndex == indexPath.row
            cell2.lblTitle.text = song.title
            cell2.lblArtistAlbum.text =  "\(song.albumArtist) - \(song.albumTitle)"
            cell2.imgStatus.image = isPlaying ? playingSongImage : nil
            cell2.imgArtwork.image = song.getArtworkWithSize(cell2.imgArtwork.frame.size)
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let mode = LibraryManager.currentPlayMode
        switch (mode) {
            case (.Artist), (.Album) : return 40.0
            default: return 50.0
        }
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var song = LibraryManager.groupedPlaylist[indexPath.section][indexPath.row]
        MusicPlayer.playSongInPlaylist(song)
        RootController.switchToMainView()
    }
    
    override func tableView(tableView: UITableView!, viewForHeaderInSection section: Int) -> UIView! {
        switch (LibraryManager.currentPlayMode) {
            case (.Artist), (.Album) :
                var cell = tableView.dequeueReusableCellWithIdentifier("PlaylistAlbumTitleCell") as PlaylistAlbumTitleCell
                var song = LibraryManager.groupedPlaylist[section][0]
                cell.lblAlbum.text = song.albumTitle
                cell.lblYear.text = song.year
                cell.imgArtwork.image = song.getArtworkWithSize(cell.imgArtwork.frame.size)
            return cell.contentView
            default: return nil
        }
    }
    
    override func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        return 75
    }
}
