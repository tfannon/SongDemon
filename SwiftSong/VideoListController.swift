//
//  VideosController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/31/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit

class VideoListController : UITableViewController {
    
    @IBOutlet var lblHeader: UILabel!
    
    var data : [JSON] = [JSON]()
    //var nextToken : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.blackColor()
        //empty cells wont create lines
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.tintColor = UIColor.whiteColor()
        self.refreshControl?.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl?.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        redrawList()
    }
    
    func refresh(sender:AnyObject) {
        //redrawList()
        //TODO: change this to go fetch the next
        self.refreshControl?.endRefreshing()
    }
    
    func redrawList(forceRefresh : Bool = false) {
        lblHeader.text = ""
        tableView.reloadData()
        if (gVideos.NeedsRefresh || forceRefresh) && gVideos.State == VideoState.Available {
            if let json = gVideos.jsonVideos {
                //println(self.nextToken)
                self.data = json["items"].array!
                //let n  = json["nextPageToken"]
                //println(data!.count)
                gVideos.NeedsRefresh = false
                if let song = MusicPlayer.currentSong {
                    lblHeader.text = "\(song.albumArtist) - \(song.title)"
                }
            }
        }
        if Utils.inSimulator {
            lblHeader.text = "Goatwhore - In Deathless Tradition"
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let x = self.data[indexPath.row]
        //let snippet = x["snippet"].object!
        //let title = x["snippet"]["title"].string!
        let description = x["snippet"]["description"].string!
        let thumb = x["snippet"]["thumbnails"]["default"]["url"].string!
        let cell = tableView.dequeueReusableCellWithIdentifier("VideoCell", forIndexPath: indexPath) as! VideoCell
        cell.lblDescription.text = description
        //clear the image before the async fetch
        if !Utils.inSimulator {
            cell.imageView!.image = nil
        }
        //go fetch the image form the thumb
        let imgURL = NSURL(string: thumb)!
        let request: NSURLRequest = NSURLRequest(URL: imgURL)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse?,data: NSData?,error: NSError?) -> Void in
            if error == nil {
                cell.imgVideo.image = UIImage(data: data!)
            }
            else {
                print("Error: \(error!.localizedDescription)")
            }
        })
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let x = self.data[indexPath.row]
        let id = x["id"]["videoId"].string!
        
        let vc = RootController.getPlayVideoController()
        let videoUrl = "https://www.youtube.com/watch?v=\(id)"
        let artworkUrl = x["snippet"]["thumbnails"]["default"]["url"].string!

        vc.loadVideo(videoUrl, artworkUrl: artworkUrl)
        RootController.switchToPlayVideoController()
    }
    
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100
    }
}
