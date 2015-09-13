//
//  PlaylistController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/4/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import MediaPlayer

protocol ICellIsPlaying {
    var imgStatus : UIImageView! { get }
}

class PlaylistController: UITableViewController {

    var sampleArtists = ["Goatwhore", "Goatwhore"]
    var sampleAlbums = ["Blood For The Master", "Constricting Rage of the Merciless"]
    var sampleSongs = ["In Deathless Tradition", "FBS"]
    var sampleImages = ["sample-album-art.jpg", "sample-album-art2.jpg"]
    
    @IBOutlet var lblHeaderTitle: UILabel!
    @IBOutlet var viewHeader: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //if no image exists dont screw up image
        //playingSongImage = playingSongImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
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
        }
        else {
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
                let songsInSection = LibraryManager.groupedPlaylist[section].count
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

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        //println("Sections: \(LibraryManager.groupedPlaylist.count)")
        return LibraryManager.groupedPlaylist.count
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if Utils.inSimulator {
            return sampleSongs.count
        }
        return LibraryManager.groupedPlaylist[section].count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let mode = LibraryManager.currentPlayMode
        var identifier : String
        switch (mode) {
            case (.Artist), (.Album)  : identifier = "PlaylistAlbumSongCell"
            default: identifier = "PlaylistCell"
        }
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier, forIndexPath: indexPath) 
        
        if Utils.inSimulator {
            let cell2 = cell as! PlaylistCell
            cell2.lblTitle.text = sampleSongs[indexPath.row]
            cell2.lblArtistAlbum.text = "\(sampleArtists[indexPath.row]) - \(sampleAlbums[indexPath.row])"
            cell2.imgArtwork.image = UIImage(named: sampleImages[indexPath.row])
            cell2.imgStatus.tintColor = UIColor.lightGrayColor()
            return cell2
        }
        
        var song : MPMediaItem;
        var isCurrentSong : Bool
        switch (mode) {
        
        case (.Artist), (.Album):
            song = LibraryManager.groupedPlaylist[indexPath.section][indexPath.row]
            isCurrentSong = getIndexPath() == indexPath
            let cell2 = cell as! PlaylistAlbumSongCell
            cell2.lblTrack.text = "\(song.albumTrackNumber)"
            cell2.lblTitle.text = song.title
            setIsPlayingImage(cell2, cellIsSelectedSong: isCurrentSong)
           
        default:
            let cell2 = cell as! PlaylistCell
            song = LibraryManager.groupedPlaylist[0][indexPath.row]
            isCurrentSong = LibraryManager.currentPlaylistIndex == indexPath.row
            cell2.lblTitle.text = song.title
            cell2.lblArtistAlbum.text =  "\(song.albumArtist) - \(song.albumTitle)"
            setIsPlayingImage(cell2, cellIsSelectedSong: isCurrentSong)
            cell2.imgArtwork.image = song.getArtworkWithSize(cell2.imgArtwork.frame.size)
        }
        
        return cell
    }
    
    func setIsPlayingImage(cell : ICellIsPlaying, cellIsSelectedSong : Bool) {
        if cellIsSelectedSong {
            //cell.imgStatus.setAnimatableImage(named: "animated_music_bars.gif")
            cell.imgStatus.image = UIImage(named: "black-red-note-120.png")
            if MusicPlayer.isPlaying {
                //cell.imgStatus.startAnimatingGIF()
            }
            cell.imgStatus.hidden = false
        }
        else {
            //cell.imgStatus.stopAnimatingGIF()
            cell.imgStatus.hidden = true
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let mode = LibraryManager.currentPlayMode
        switch (mode) {
            case (.Artist), (.Album) : return 35.0
            default: return 50.0
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let song = LibraryManager.groupedPlaylist[indexPath.section][indexPath.row]
        //println(song.songInfo)
        MusicPlayer.playSongInPlaylist(song)
        RootController.switchToMainView()
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView {
        switch (LibraryManager.currentPlayMode) {
            case (.Artist), (.Album) :
                let cell = tableView.dequeueReusableCellWithIdentifier("PlaylistAlbumTitleCell") as! PlaylistAlbumTitleCell
                let song = LibraryManager.groupedPlaylist[section][0]
                cell.lblAlbum.text = song.albumTitle
                cell.lblYear.text = song.year
                cell.lblArtist.text = song.albumArtist
                cell.imgArtwork.image = song.getArtworkWithSize(cell.imgArtwork.frame.size)
                //cell.contentView.backgroundColor = UIColor.darkGrayColor()
                cell.contentView.backgroundColor = UIColor.blackColor()
            return cell.contentView
            default:
                let cell = tableView.dequeueReusableCellWithIdentifier("PlaylistAlbumTitleCell") as! PlaylistAlbumTitleCell
                cell.contentView.backgroundColor = UIColor.blackColor()
                return cell.contentView
        }
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch (LibraryManager.currentPlayMode) {
            case (.Artist), (.Album) : return 115
            default: return 25
        }
    }
}
