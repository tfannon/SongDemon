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
    
    
    var Albums : [([MPMediaItem])]?
    /*
    func setArtistAlbums(artistAlbums : [([MPMediaItem])]? = nil) {
        println("\(artistAlbums!.count)")
        var albums : [Album] = artistAlbums!.map { item in
            var album = Album(title: item[0].albumTitle)
            album.image = item[0].artwork!.description
            println(album.image)
            album.year =  item[0].year
            var songs : [Song] = item.map { songItem in
                var song = Song(title: songItem.title)
                song.trackNumber = songItem.albumTrackNumber
                album.addSong(song)
                return song
            }
            return album
        }
        self.Albums = albums
    }
    
    
    class Album : NSObject {
        let title : String
        var image : String?
        var year: String?
        var songs = [Song]()
        func addSong(song : Song) {
            songs.append(song)
        }
        init(title: String) {
            self.title = title
        }
    }
    
    class Song : NSObject {
        var title : String
        var trackNumber : Int?
        init(title: String) {
            self.title = title
        }
    }
    */
    
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
