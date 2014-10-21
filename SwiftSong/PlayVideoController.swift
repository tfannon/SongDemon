//
//  PlayVideoController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 9/1/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import WebKit

class PlayVideoController : UIViewController {
    
    var myWeb = WKWebView()
    var currentVideoUrl = ""
    var currentArtworkUrl = ""
  
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myWeb.frame=CGRectMake(0, 32, 320, 560-32)
        self.view.addSubview(myWeb)
    }
    
    func loadVideo(videoUrl : String, artworkUrl : String) {
        if !videoUrl.isEmpty && videoUrl != currentVideoUrl {
            println("loading video:\(videoUrl)")
            let requestURL = NSURL(string: videoUrl)
            let request = NSURLRequest(URL: requestURL!)
            myWeb.loadRequest(request)
            currentVideoUrl = videoUrl
            currentArtworkUrl = artworkUrl
        }
        else {
            println("video already loaded")
        }
    }
}
