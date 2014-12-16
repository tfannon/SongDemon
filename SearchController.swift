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
    }
    
    override func viewWillAppear(animated: Bool) {
        if currentlyPlayingArtist != nil {
            var searchAlbumController = self.tabBarController!.viewControllers![1] as SearchAlbumController
            searchAlbumController.selectArtist(currentlyPlayingArtist!)
            self.selectedIndex = 0
        }
        else {
            self.selectedIndex = 1
        }
    }
}
