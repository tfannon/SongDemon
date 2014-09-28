//
//  Videos.swift
//  SongDemon
//
//  Created by Tommy Fannon on 8/31/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//
import Foundation
import MediaPlayer

let gVideos = Videos()
let apiKey = "AIzaSyDcpJS_v-iEX3eojZ7hsamDVvyrnQAyTdE"
let maxResults = 25

enum VideoState {
    case Available
    case Displayed
    case NotAvailable
    case Fetching
}

class Videos {

    var State = VideoState.Fetching
    var jsonVideos : JSONValue? = nil
    //this signals the the catched list has changed and the VideoListController will need to repaint
    var NeedsRefresh = true
    //we store this because if the one coming in is the same, its a noop
    var CurrentUrl = ""
  
    
    class func fetchVideosFor(item: MPMediaItem?) {
        if !Utils.inSimulator && item == nil { return }
        
        gLyrics.State = .Fetching
        
        var query = Utils.inSimulator ?
            "Goatwhore In Deathless Tradition" :
            "\(item!.albumArtist) \(item!.title)"
        
        
        var urlStr = "https://www.googleapis.com/youtube/v3/search?key=\(apiKey)&part=snippet&q='\(query)'&type=video& order=viewCount&maxResults=\(maxResults)"

        urlStr = urlStr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        //if there is no fetched url yet or the url is different than last one
        if gVideos.CurrentUrl.isEmpty || gVideos.CurrentUrl != urlStr {
            println("Loading google json async for: \(query)")

            let url = NSURL.URLWithString(urlStr)
            let request = NSURLRequest(URL: url)
        
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
            (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
             
                if error != nil {
                    println("Error in videos fetch Connection: \(error)")
                    println()
                    gVideos.State = .NotAvailable
                    gVideos.NeedsRefresh = true
                    return
                }
    
                var jsonError: NSError?
                var json : AnyObject! = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as NSDictionary
    
                if jsonError != nil {
                    println("Error in JSON: \(jsonError)")
                    gVideos.State = .NotAvailable
                    gVideos.NeedsRefresh = true
                    return
                }
    
                var parsedJson = JSONValue(json)
                //println(parsedJson)
                
                gVideos.jsonVideos = parsedJson
                gVideos.State = .Available
                gVideos.NeedsRefresh = true
            
                var items = parsedJson["items"].array!
                if items.count == 0 {
                    return;
                }
                let currentVid = items[0]
                let id = currentVid["id"]["videoId"].string!

                let vc = RootController.getPlayVideoController()
            
                let url = "https://www.youtube.com/watch?v=\(id)"
                vc.loadAddressURL(url)
                gVideos.CurrentUrl = urlStr
            })
        } else {
            println("using cached google json")
        }
    }
}

