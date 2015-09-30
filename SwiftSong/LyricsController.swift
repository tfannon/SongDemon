//
//  LyricsController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 7/29/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import WebKit

//had to put key in plist for NSAppTransportSecurity iOS9.0
class LyricsController: UIViewController {

    var webView = WKWebView()
    var currentUrl = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.frame=CGRectMake(0, 32, self.view.frame.width, self.view.frame.height-32)
        self.view.addSubview(webView)
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    func loadLyrics(url : String) {
        if !url.isEmpty && url != currentUrl {
            print("loading lyrics:\(url)")
            let requestURL = NSURL(string: url)
            let request = NSURLRequest(URL: requestURL!)
            self.webView.loadRequest(request)
            currentUrl = url
        }
        else {
            print("lyrics already loaded")
        }
    }
}
