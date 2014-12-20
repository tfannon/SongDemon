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
        if Utils.inSimulator {
            return cell
        }
        cell.lblArtist.text = artist.name
        cell.imgArtist.image = UIImage(named: "blacklab2")
        let artistInfo = LibraryManager.artistInfo[artist.name]!
        if let artwork = artistInfo.artwork {
            cell.imgArtist.image = artwork.imageWithSize(cell.imgArtist.frame.size)
        }
        let information = "\(artistInfo.songs) songs  \(artistInfo.likedSongs) liked  \(artistInfo.unplayedSongs) unplayed"
        cell.lblInformation.text = information
        return cell
    }
    
        /* LastFM

        var urlStr = "http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=\(artist.name)&api_key=\(LastFMAPIKey)&format=json"

        urlStr = urlStr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!

        let url = NSURL(string: urlStr)!
        let request = NSURLRequest(URL: url)
        //println("requesting \(urlStr)")

        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
            (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in

            if error != nil {
                println("Error requesting \(urlStr): \(error.localizedDescription)")
                return;
            }

            var jsonError: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as NSDictionary

            if jsonError != nil {
                println("Error with LastFM json: \(jsonError)")
                return
            }
            
            let parsedJson = JSONValue(data)
            //println(parsedJson)
            let x = parsedJson["artist"]
            let images = x["image"].array!
            println(images)
            //let med = images[1]["#text"].string
            let xlrg = images[4]["#text"].string
        
            //fetch the json from last.fm
            if let urlString = xlrg {
                if urlString.isEmpty {
                    return
                }
                //println("urlstring:\(urlString) lrg:\(lrg)")
                var image = self.imageCache[urlString]
                if image == nil {
                    // If the image does not exist, we need to download it
                    var imgURL: NSURL = NSURL(string: urlString)!
                    let request: NSURLRequest = NSURLRequest(URL: imgURL)
                    NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {(response: NSURLResponse!,data: NSData!,error: NSError!) -> Void in

                        if error != nil {
                            println("Error fetching image \(urlString): \(error.localizedDescription)")
                            return
                        }

                        image = UIImage(data: data)
                        image = RBResizeImage(image!, cell.imgArtist.frame.size)
                        // Store the image in to our cache
                        self.imageCache[urlString] = image
                        self.updateCell(cell, image: image!)
                    })
                } else {
                    self.updateCell(cell, image: image!)
                }
            }
        })
        return cell
    }


    func updateCell(cell : SearchArtistCell, image : UIImage) {
        Async.main {
            //get the cell to update, resize the image to fit the cell, set it in cell
            //f let cellToUpdate = tableView.cellForRowAtIndexPath(indexPath) {
            //    var cell2 = cellToUpdate as SearchArtistCell
                cell.imgArtist.image = image
            //}
        }
    }
*/
    
    
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
        var searchAlbumController = self.tabBarController!.viewControllers![1] as SearchAlbumController
        searchAlbumController.selectedArtist = artist
        searchAlbumController.artistSelectedWithPicker = true
        self.tabBarController!.selectedIndex = 1
    }
}
