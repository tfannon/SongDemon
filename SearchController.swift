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
    
    var currentSong : MPMediaItem?
    var previousSong : MPMediaItem?
    
    @IBAction func handleCancelClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnCancel.center = self.tabBar.center
        self.view.addSubview(btnCancel)
    }
    
    override func viewWillAppear(animated: Bool) {
        println("SearchController about to appear")
        self.selectedIndex = 1
    }
  }
