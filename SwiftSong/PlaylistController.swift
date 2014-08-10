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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playingSongImage = playingSongImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        //self.tableView.backgroundColor = UIColor.blackColor()

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
        let cell = tableView.dequeueReusableCellWithIdentifier("PlaylistCell", forIndexPath: indexPath) as PlaylistCell
        
        if Utils.inSimulator {
            cell.lblTitle.text = sampleSongs[indexPath.row]
            cell.lblArtistAlbum.text = "\(sampleArtists[indexPath.row]) - \(sampleAlbums[indexPath.row])"
            cell.imgArtwork.image = UIImage(named: sampleImages[indexPath.row])
            cell.imgStatus.tintColor = UIColor.lightGrayColor()
            cell.imgStatus.image = playingSongImage
            return cell
        }
        
        let song = LibraryManager.currentPlaylist[indexPath.row]
        cell.lblTitle.text = song.title
        cell.lblArtistAlbum.text = "\(song.albumArtist) - \(song.albumTitle)"
        if LibraryManager.currentPlaylistIndex == indexPath.row {
            cell.imgStatus.image = playingSongImage
        } else {
            cell.imgStatus.image = nil
        }
        if song.artwork != nil {
            cell.imgArtwork.image = song.artwork.imageWithSize(cell.imgArtwork.frame.size)
        } else {
            cell.imgArtwork.image = nil
        }
        return cell
    }
    
    override func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        println("didSelectRowAtIndexPath called")
        var song = LibraryManager.currentPlaylist[indexPath.row]
        MusicPlayer.playSongInPlaylist(song)
        RootController.switchToMainView()
    }
    
    override func tableView(tableView: UITableView!, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }



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
