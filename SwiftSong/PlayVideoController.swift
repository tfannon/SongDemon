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
    var currentUrl = ""

    @IBOutlet var btnBack: UIButton!
    @IBAction func backTapped(sender: AnyObject) {
        self.dismissViewControllerAnimated(false, completion: {})
        RootController.switchToVideoListController()
    }
    
    override func shouldAutorotate() -> Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        myWeb.frame=CGRectMake(0, 60, 320, 560-60)
        self.view.addSubview(myWeb)
        configureWebView()
    }
    
    func configureWebView() {
        //myWeb.delegate=self
        //myWeb.backgroundColor = UIColor.blackColor()
        //myWeb.scalesPageToFit = true
        //myWeb.dataDetectorTypes = .All
    }
    
    
    func loadAddressURL(url : String) {
        if !url.isEmpty && url != currentUrl {
            println("loading video:\(url)")
            let requestURL = NSURL(string: url)
            let request = NSURLRequest(URL: requestURL)
            myWeb.loadRequest(request)
            currentUrl = url
        }
        else {
            println("video already loaded")
        }
    }
}
