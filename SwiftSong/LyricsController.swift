//
//  LyricsController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 7/29/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit

class LyricsController: UIViewController {

    @IBOutlet var webView: UIWebView!
    //note: we are setting opaque property to NO so it takes on color of background before loading otherwise it is white
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        if gLyrics.NeedsRefresh && gLyrics.Url != nil {
            webView.loadRequest(NSURLRequest(URL: gLyrics.Url))
        }
        gLyrics.NeedsRefresh = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
