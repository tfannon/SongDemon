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
    
    //vr currentSong : MPMediaItem?
    var previousArtist : String?
    var songsByAlbum : [[MPMediaItem]] = []
    
    override func viewDidLoad() {
        self.tableView.dataSource = self
        self.tableView.delegate = self
        //if no image exists dont screw up image
        //playingSongImage = playingSongImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        self.tableView.backgroundColor = UIColor.blackColor()
        //empty cells wont create lines
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.None
        reloadCheck()
    }
    
    override func viewWillAppear(animated: Bool) {
        reloadCheck()
    }
    
    func reloadCheck() {
        println ("reload check")
        if let currentSong = MusicPlayer.currentSong {
            //the artist has changed.  need to reload
            if previousArtist == nil || currentSong.albumArtist! != previousArtist! {
                let artist = currentSong.albumArtist!
                self.lblArtist.text = artist
                let songsByAlbum = LibraryManager.getArtistSongsWithoutSettingPlaylist(artist)
                self.tableView.reloadData()
            }
            //otherwise nothing changed.  just
        }
            //no current song playing, bounce back to artist picker
        else {
            self.tabBarController!.selectedIndex = 0
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
        println ("sections: \(songsByAlbum.count)")
        return songsByAlbum.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println ("rows in \(section): \(songsByAlbum.count)")
        return songsByAlbum[section].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchAlbumTrackCell") as SearchAlbumTrackCell
        let song = songsByAlbum[indexPath.section][indexPath.row]
        cell.lblTitle.text = song.title
        cell.lblTrackNumber.text = "\(song.albumTrackNumber)"
        return cell
    }
    
    //header
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var cell = tableView.dequeueReusableCellWithIdentifier("SearchAlbumTitleCell") as SearchAlbumTitleCell
        let album = songsByAlbum[section]
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
