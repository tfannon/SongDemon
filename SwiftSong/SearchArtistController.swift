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
        //UITableView.appearance().sectionIndexTrackingBackgroundColor = UIColor.blackColor()
        UITableView.appearance().sectionIndexBackgroundColor = UIColor.blackColor()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if MusicPlayer.currentSong != nil {
            let indexPath = getIndexPathForCurrentSong()
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Middle, animated: false)
        }
    }
    
    func getIndexPathForCurrentSong() -> NSIndexPath {
        if let currentSong = MusicPlayer.currentSong {
            let name = currentSong.albumArtist!
            let section = self.collation.sectionForObject(Artist(name: name), collationStringSelector: "name")
            let x = sections[section]
            let names: [String] = x.artists.map { $0.name }
            if let row = names.indexOf(name) {
                return  NSIndexPath(forRow: row, inSection: section)
            }
        }
        return NSIndexPath(forRow: 0, inSection: 0)
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
            as! SearchArtistCell
        if Utils.inSimulator {
            return cell
        }
        cell.lblArtist.text = artist.name
        cell.imgArtist.image = UIImage(named: "jakegiz")
        let artistInfo = LibraryManager.artistInfo[artist.name]!
//        if let artwork = artistInfo.artwork {
//            cell.imgArtist.image = artwork.imageWithSize(cell.imgArtist.frame.size)
//        }
        let information = "\(artistInfo.songs) songs  \(artistInfo.likedSongs) liked  \(artistInfo.unplayedSongs) unplayed"
        cell.lblInformation.text = information
        return cell
    }
    

    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if !self.sections[section].artists.isEmpty {
            return (self.collation.sectionTitles[section] )
        }
        return ""
    }
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
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
    
    let collation = UILocalizedIndexedCollation.currentCollation() 
    
    var _sections: [Section]?
    var sections: [Section] {
        if self._sections != nil {
            return self._sections!;
        }
        
        //create artists from itunes list
        let artists: [Artist] = names.map { name in
            let artist = Artist(name: name)
            artist.section = self.collation.sectionForObject(artist, collationStringSelector: "name")
            return artist
        }
        
        //create empty sections
        var sections = [Section]()
        for _ in 0..<self.collation.sectionIndexTitles.count {
            sections.append(Section())
        }
        
        //put each artist in a section
        for artist in artists {
            sections[artist.section!].addArtist(artist)
        }
        
        //sort each section
        for section in sections {
            section.artists = self.collation.sortedArrayFromArray(section.artists, collationStringSelector: "name") as! [Artist]
        }
        
        self._sections = sections
        return self._sections!
    }
    
    //MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let artist = self.sections[indexPath.section].artists[indexPath.row].name
        let searchAlbumController = self.tabBarController!.viewControllers![1] as! SearchAlbumController
        searchAlbumController.selectedArtist = artist
        searchAlbumController.artistSelectedWithPicker = true
        self.tabBarController!.selectedIndex = 1
        self.tableView.deselectRowAtIndexPath(indexPath, animated: false)
    }
}
