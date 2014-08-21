//
//  PlaylistController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/4/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit

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
        
        return LibraryManager.currentPlaylist.count
    }

    override func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        let mode = LibraryManager.currentPlayMode
        var identifier : String
        switch mode {
            case .Artist : identifier = "PlaylistArtistModeCell"
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
        
        let song = LibraryManager.currentPlaylist[indexPath.row]
        let isPlaying = LibraryManager.currentPlaylistIndex == indexPath.row
    
        if mode == PlayMode.Artist {
            let cell2 = cell as PlaylistArtistModeCell
            cell2.lblTrack.text = "\(song.albumTrackNumber)"
            cell2.lblTitle.text = song.title
            cell2.imgStatus.image = isPlaying ? playingSongImage : nil
        } else {
            let cell2 = cell as PlaylistCell
            cell2.lblTitle.text = song.title
            cell2.lblArtistAlbum.text =  "\(song.albumArtist) - \(song.albumTitle)"
            cell2.imgStatus.image = isPlaying ? playingSongImage : nil
            let image = song.artwork != nil ? song.artwork.imageWithSize(cell2.imgArtwork.frame.size) : nil
            cell2.imgArtwork.image = image
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        //println("didSelectRowAtIndexPath called")
        var song = LibraryManager.currentPlaylist[indexPath.row]
        MusicPlayer.playSongInPlaylist(song)
        RootController.switchToMainView()
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
