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
    var NeedsRefresh = true
    
    
    class func fetchVideosFor(item: MPMediaItem?) {
        gLyrics.State = .Fetching
        var query = ""
        if Utils.inSimulator {
            query = "Goatwhore In Deathless Tradition"
        } else if item != nil {
            query = "\(item!.albumArtist) \(item!.title)"
        }
        
        var urlStr = "https://www.googleapis.com/youtube/v3/search?key=\(apiKey)&part=snippet&q='\(query)'&type=video& order=viewCount&maxResults=\(maxResults)"
        urlStr = urlStr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)
        println(urlStr)
        
        let url = NSURL.URLWithString(urlStr)
        let request = NSURLRequest(URL: url)

    
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
                println(parsedJson)
                
                gVideos.jsonVideos = parsedJson
                gVideos.State = .Available
                gVideos.NeedsRefresh = true
        })
    }
}

