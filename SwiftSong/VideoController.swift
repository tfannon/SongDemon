//
//  VideosController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/31/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit

class VideoController : UITableViewController {
    var data : [JSONValue]?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor.blackColor()
        //empty cells wont create lines
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl.tintColor = UIColor.whiteColor()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: "refresh:", forControlEvents: UIControlEvents.ValueChanged)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }
    
    func refresh(sender:AnyObject) {
        redrawList()
        self.refreshControl.endRefreshing()
    }
    
    override func viewDidAppear(animated: Bool) {
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        redrawList()
    }
    
    
    func redrawList(forceRefresh : Bool = true) {
        tableView.reloadData()
        if (gVideos.NeedsRefresh || forceRefresh) && gVideos.State == VideoState.Available {
            if let json = gVideos.jsonVideos {
                data = json["items"].array
                //println(data!.count)
                gVideos.NeedsRefresh = false
            }
        }
    }

}
