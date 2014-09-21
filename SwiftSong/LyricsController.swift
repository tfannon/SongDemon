//
//  LyricsController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 7/29/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import WebKit

class LyricsController: UIViewController {

    @IBOutlet var containerView: UIView!

    var webView = WKWebView()
    var currentUrl = ""
    
    //note: we are setting opaque property to NO so it takes on color of background before loading otherwise it is white

    
    override func loadView() {
        super.loadView()
        //self.webView = WKWebView()
        //self.view = self.webView!
    }
    
    override func viewDidLoad() {
        self.view = self.webView
        /*
        super.viewDidLoad()
        var url = NSURL(string:"http://www.kinderas.com/")
        var req = NSURLRequest(URL:url)
        self.webView!.loadRequest(req)
        
        myWeb.frame=CGRectMake(0, 60, 320, 560-60)
        self.view.addSubview(myWeb)
        configureWebView()
        */
    }
    
    func configureWebView() {
        //myWeb.delegate=self
        //myWeb.backgroundColor = UIColor.blackColor()
        //myWeb.scalesPageToFit = true
        //myWeb.dataDetectorTypes = .All
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func viewDidAppear(animated: Bool) {
        //if gLyrics.NeedsRefresh && gLyrics.Url != nil {
        //    webView.loadRequest(NSURLRequest(URL: gLyrics.Url))
        //}
        //gLyrics.NeedsRefresh = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func loadAddressUrl(url : String) {
        if !url.isEmpty && url != currentUrl {
            println("loading lyrics:\(url)")
            let requestURL = NSURL(string: url)
            let request = NSURLRequest(URL: requestURL)
            self.webView.loadRequest(request)
            currentUrl = url
        }
        else {
            println("lyrics already loaded")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
