//
//  PlayVideoController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 9/1/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit

class PlayVideoController : UIViewController, UIWebViewDelegate {
    
    var myWeb = UIWebView()

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
        //TODO: make this dynamic
        myWeb.frame=CGRectMake(0, 51, 320, 560-51)
        self.view.addSubview(myWeb)
        
        configureWebView()
        //loadAddressURL()
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    func configureWebView() {
        myWeb.delegate=self
        myWeb.backgroundColor = UIColor.blackColor()
        //myWeb.scalesPageToFit = true
        //myWeb.dataDetectorTypes = .All
    }
    
    
    func loadAddressURL(url : String) {
        println("loading video:\(url)")
        let requestURL = NSURL(string: url)
        let request = NSURLRequest(URL: requestURL)
        myWeb.loadRequest(request)
    }
    
    func loadHtml(html : String) {
        myWeb.loadHTMLString(html, baseURL: nil)
    }
    
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError) {
        // Report the error inside the web view.
        let localizedErrorMessage = NSLocalizedString("An error occured:", comment: "")
        
        let errorHTML = "<!doctype html><html><body><div style=\"width: 100%%; text-align: center; font-size: 36pt;\">\(localizedErrorMessage) \(error.localizedDescription)</div></body></html>"
        
        webView.loadHTMLString(errorHTML, baseURL: nil)
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
    func webViewDidStartLoad(_: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    }
    
    func webViewDidFinishLoad(_: UIWebView) {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
    }
    
}
