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
    
    
    override func viewDidLoad() {
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
        if dirty {
            self.tableView.reloadData()
        }
    }
    
    var dirty : Bool = false
    
    var Albums : [([MPMediaItem])]? {
        didSet {
            dirty = true
        }
    }
    
    var albums =
    [
        "Constricting Rage of the Merciless",
        "Blood For The Master"
    ]
    
    var songs =
    [[
        "Poisonous Existence in Reawakening",
        "Unraveling Paradise",
        "Baring Teeth for Revolt",
        "Reanimated Sacrifice",
        "Heaven's Crumbling Walls of Pity",
        "Cold Earth Consumed in Dying Flesh",
        "FBS",
        "Nocturnal Conjuration of the Accursed",
        "Schadenfruede",
        "Externalize This Hidden Savagery"
     ],
     [
        "Collapse in Eternal Worth",
        "When Steel and Bone Meet"
    ]]
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Albums!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Albums![section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchAlbumTrackCell") as SearchAlbumTrackCell
        let song = Albums![indexPath.section][indexPath.row]
        cell.lblTitle.text = song.title
        cell.lblTrackNumber.text = "\(song.albumTrackNumber)"
        return cell
    }
    
    //header
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var cell = tableView.dequeueReusableCellWithIdentifier("SearchAlbumTitleCell") as SearchAlbumTitleCell
        let album = Albums![section]
        cell.lblTitle.text = album[0].albumTitle
        cell.imgAlbum.image = album[0].getArtworkWithSize(cell.imgAlbum.frame.size)
        cell.lblInfo.text = album[0].year
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 40.0
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 65.0
    }
}