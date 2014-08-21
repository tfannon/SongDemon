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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playingSongImage = playingSongImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.tableView.backgroundColor = UIColor.blackColor()
        
        self.tableView.tableFooterView = UIView(frame: CGRectZero)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        redrawList()
    }
    
    func redrawList() {
        tableView.reloadData()
        var text = LibraryManager.currentPlaylist.count == 0 ? "No playlist selected" : ""
        lblHeaderTitle.text = text
        var index = LibraryManager.currentPlaylistIndex
        if index >= 0 {
            var indexPath = NSIndexPath(forRow: index, inSection: 0)
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: true)
        }
    }


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        // #warning Potentially incomplete method implementation.
        // Return the number of sections.
        return 1
    }

    override func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        if Utils.inSimulator {
            return sampleSongs.count
        }
        var count = LibraryManager.currentPlaylist.count
        switch (LibraryManager.currentPlayMode) {
            case (.Album), (.Artist) : count++
            default:""
        }
        return count
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let mode = LibraryManager.currentPlayMode
        var identifier : String
        switch (mode,indexPath.row) {
            case (.Artist, 0), (.Album, 0) :  identifier = "PlaylistAlbumTitleCell"
            case (.Artist, _), (.Album, _)  : identifier = "PlaylistAlbumSongCell"
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
        switch (mode, indexPath.row) {
        
        case (.Artist, 0), (.Album, 0) :
            song = LibraryManager.currentPlaylist[indexPath.row]
            let cell2 = cell as PlaylistAlbumTitleCell
            cell2.lblArtist.text = song.albumArtist
            cell2.lblAlbum.text = song.albumTitle
            cell2.imgArtwork.image = song.artwork != nil ? song.artwork.imageWithSize(cell2.imgArtwork.frame.size) : nil

        case (.Artist, _), (.Album, _):
            song = LibraryManager.currentPlaylist[indexPath.row-1]
            isPlaying = LibraryManager.currentPlaylistIndex == indexPath.row-1
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
            let image = song.artwork != nil ? song.artwork.imageWithSize(cell2.imgArtwork.frame.size) : nil
            cell2.imgArtwork.image = image
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView!, heightForRowAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let mode = LibraryManager.currentPlayMode
        switch (mode,indexPath.row) {
            case (.Artist, 0), (.Album, 0) : return 75.0
            case (.Artist, _), (.Album, _) : return 40.0
            default: return 50.0
        }

    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        var song : MPMediaItem
        switch (LibraryManager.currentPlayMode) {
        case (.Artist), (.Album) :
            if indexPath.row > 0 {
                song = LibraryManager.currentPlaylist[indexPath.row-1]
                MusicPlayer.playSongInPlaylist(song)
            }
            RootController.switchToMainView()

        default:
            song = LibraryManager.currentPlaylist[indexPath.row]
            MusicPlayer.playSongInPlaylist(song)
            RootController.switchToMainView()
        }
    }
    
    /*
    override func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }

    
    override func tableView(tableView: UITableView!, willDisplayHeaderView view: UIView!, forSection section: Int) {
        view.tintColor = UIColor.blackColor()
    }
    */
    


    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView!, canEditRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView!, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath!) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView!, moveRowAtIndexPath fromIndexPath: NSIndexPath!, toIndexPath: NSIndexPath!) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView!, canMoveRowAtIndexPath indexPath: NSIndexPath!) -> Bool {
        // Return NO if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

}
