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

enum VideoState {
    case Available
    case Displayed
    case NotAvailable
    case Fetching
}

class Videos {

    var State = VideoState.Fetching
    var jsonVideos : JSONValue? = nil
    var NeedsRefresh = true
    
    
    class func fetchVideosFor(item: MPMediaItem?) {
        gLyrics.State = .Fetching
        
        //if Utils.inSimulator {
            gLyrics.NeedsRefresh = true
            let url = NSURL.URLWithString("https://www.googleapis.com/youtube/v3/search?key=\(apiKey)&part=snippet&q='Goatwhore In Deathless Tradition'&order=viewCount".stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding))
    
            let request = NSURLRequest(URL: url)
            //request.setValue ("application/json", forHtt: <#String!#>)
    
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
                (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in
             
                if error != nil {
                    println("Error in Connection: \(error)")
                    println()
                    gVideos.State = .NotAvailable
                    gVideos.NeedsRefresh = true
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
                
                gVideos.jsonVideos = parsedJson
                println(gVideos.jsonVideos)

                gVideos.State = .Available
                gVideos.NeedsRefresh = true
            })
        //}
    }
}

