//
//  SeachController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 11/27/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import MediaPlayer

class SearchController: UITabBarController {

    @IBOutlet var btnCancel: UIButton!
    
    @IBAction func handleCancelClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    var currentlyPlayingArtist : String?
   
    override func viewDidLoad() {
        super.viewDidLoad()
        btnCancel.center = self.tabBar.center
        let f = btnCancel.frame
        btnCancel.frame = CGRect(x: f.origin.x - 10, y: f.origin.y, width: f.width + 20, height: f.height)
        self.view.addSubview(btnCancel)
        
        
        //swiping up allows user to select playlist
        let swipeUp = UISwipeGestureRecognizer(target: self, action: "handleCancelClicked:")
        swipeUp.direction = .Up
        view.addGestureRecognizer(swipeUp)
    }
    
    override func viewWillAppear(animated: Bool) {
        //we have to account for the fact that a song may be playing that is not in the system
        if currentlyPlayingArtist != nil && LibraryManager.hasArtist(currentlyPlayingArtist!) {
            let searchAlbumController = self.viewControllers![1] as! SearchAlbumController
            searchAlbumController.selectedArtist = currentlyPlayingArtist!
            searchAlbumController.artistSelectedWithPicker = false
            self.selectedIndex = 1
        }
        else {
            self.selectedIndex = 0
        }
    }
}
