//
//  SongSearchController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 11/15/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import MediaPlayer

class SearchArtistController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var tableView: UITableView!
   
    var imageCache = [String : UIImage]()
    var previousArtist : String! = nil
    let names = Utils.inSimulator ? ["Goatwhore", "Sleep"] : ITunesUtils.getArtists()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.blackColor()
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if MusicPlayer.currentSong != nil {
            let indexPath = getIndexPathForCurrentSong()
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
        }
    }
    
    func getIndexPathForCurrentSong() -> NSIndexPath {
        let name = MusicPlayer.currentSong!.albumArtist
        var section = self.collation.sectionForObject(Artist(name: name), collationStringSelector: "name")
        var x = sections[section]
        let names : [String] = x.artists.map { artist in
            return artist.name
        }
        let row = find(names, name)!
        let indexPath = NSIndexPath(forRow: row, inSection: section)
        return indexPath
    }

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].artists.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let artist = self.sections[indexPath.section].artists[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchArtistCell", forIndexPath: indexPath)
            as SearchArtistCell
        
        cell.lblArtist.text = artist.name
        
        //cell.lblInformation.text = ""
        //let image = LastFMUtils.fetchImageForArtist(artist)
        
        /* fetch the json from last.fm
        
        var image = self.imageCache[urlString]
        if( image == nil ) {
            // If the image does not exist, we need to download it
            var imgURL: NSURL = NSURL(string: urlString)!
            
            // Download an NSData representation of the image at the URL
            let request: NSURLRequest = NSURLRequest(URL: imgURL)
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in
                if error == nil {
                    image = UIImage(data: data)
                    
                    // Store the image in to our cache
                    self.imageCache[urlString] = image
                    dispatch_async(dispatch_get_main_queue(), {
                        if let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
                            cellToUpdate.imageView.image = image
                        }
                    })
                }
                else {
                    println("Error: \(error.localizedDescription)")
                }
            })
            
        }
*/

        
        //cell. .imageView.image = UIImage(named: "Blank52")
        //cell.lblArtist.text = "Goatwhore"
        //cell.lblInformation.text = "10 Albums"
        return cell
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !self.sections[section].artists.isEmpty {
            return (self.collation.sectionTitles[section] as String)
        }
        return ""
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [AnyObject]! {
        return self.collation.sectionIndexTitles
    }
    
    func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return self.collation.sectionForSectionIndexTitleAtIndex(index)
    }
    
    
    
    //MARK:  helpers to deal with indexing section
    class Artist : NSObject {
        let name: String
        var section: Int?
        
        init(name: String) {
            self.name = name
        }
    }
    
    class Section {
        var artists : [Artist] = []
        
        func addArtist(artist : Artist) {
            self.artists.append(artist)
        }
    }
    
    let collation = UILocalizedIndexedCollation.currentCollation() as UILocalizedIndexedCollation
    
    var _sections: [Section]?
    var sections: [Section] {
        if self._sections != nil {
            return self._sections!;
        }
        
        //create artists from itunes list
        var artists: [Artist] = names.map { name in
            var artist = Artist(name: name)
            artist.section = self.collation.sectionForObject(artist, collationStringSelector: "name")
            return artist
        }
        
        //create empty sections
        var sections = [Section]()
        for i in 0..<self.collation.sectionIndexTitles.count {
            sections.append(Section())
        }
        
        //put each artist in a section
        for artist in artists {
            sections[artist.section!].addArtist(artist)
        }
        
        //sort each section
        for section in sections {
            section.artists = self.collation.sortedArrayFromArray(section.artists, collationStringSelector: "name") as [Artist]
        }
        
        self._sections = sections
        return self._sections!
    }
    
    //MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let artist = self.sections[indexPath.section].artists[indexPath.row].name
        var items = LibraryManager.getArtistSongsWithoutSettingPlaylist(artist)
        //println(self.tabBarController!.viewControllers!.count)
        var vcs = self.tabBarController!.viewControllers! as [UIViewController]
        /*
        var albumController = vcs[1] as SearchAlbumController
            albumController.Albums = Utils.inSimulator ? [[MPMediaItem]]() : items.0
        */
        self.tabBarController!.selectedIndex = 1
    }
}
