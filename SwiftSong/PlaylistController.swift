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
    
    var playingSongImage = UIImage(named: "play-75@2x.png")
    
    @IBOutlet var lblHeaderTitle: UILabel!
    @IBOutlet var viewHeader: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //if no image exists dont screw up image
        playingSongImage = playingSongImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.tableView.backgroundColor = UIColor.blackColor()
        //empty cells wont create lines
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        redrawList()
    }
    
    
    func redrawList() {
        tableView.reloadData()
        if LibraryManager.currentPlaylist.count == 0 {
            lblHeaderTitle.text = "No playlist selected"
        } else {
            lblHeaderTitle.text = ""
            tableView.scrollToRowAtIndexPath(getIndexPath(), atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
        }
    }
    
    func getIndexPath() -> NSIndexPath {
        let index = LibraryManager.currentPlaylistIndex
        var indexPath : NSIndexPath
        if index == 0 {
            indexPath = NSIndexPath(forRow: 0, inSection: 0)
        } else {
            var idx : Int = 0
            var row = 0
            var section = 0
            while (idx < index) {
                var songsInSection = LibraryManager.groupedPlaylist[section].count
                if idx + songsInSection > index {
                    row = index - idx
                } else {
                    section++
                }
                idx += songsInSection
            }
            //println("Index:\(index)  Idx:\(idx)  Section:\(section)  Row:\(row)")
            indexPath = NSIndexPath(forRow: row, inSection: section)
        }
        return indexPath
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        //println("Sections: \(LibraryManager.groupedPlaylist.count)")
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
            isPlaying = getIndexPath() == indexPath
            let cell2 = cell as PlaylistAlbumSongCell
            cell2.lblTrack.text = "\(song.albumTrackNumber)"
            cell2.lblTitle.text = song.title
            cell2.imgStatus.image = isPlaying ? playingSongImage : nil
        
        default:
            let cell2 = cell as PlaylistCell
            song = LibraryManager.groupedPlaylist[0][indexPath.row]
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
                cell.lblArtist.text = song.albumArtist
                cell.imgArtwork.image = song.getArtworkWithSize(cell.imgArtwork.frame.size)
                //cell.contentView.backgroundColor = UIColor.darkGrayColor()
                cell.contentView.backgroundColor = UIColor.blackColor()
            return cell.contentView
            default:
                var cell = tableView.dequeueReusableCellWithIdentifier("PlaylistAlbumTitleCell") as PlaylistAlbumTitleCell
                cell.contentView.backgroundColor = UIColor.blackColor()
                return cell.contentView
        }
    }
    
    override func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        switch (LibraryManager.currentPlayMode) {
            case (.Artist), (.Album) : return 115
            default: return 25
        }
    }
}
