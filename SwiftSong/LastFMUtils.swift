//
//  LastFMUtils.swift
//  SongDemon
//
//  Created by Tommy Fannon on 11/17/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

let LastFMAPIKey = "b7361363b0bb6585af3095912ad3f7f5"

class LastFMUtils {
    
    //hit last GN
    class func fetchImageForArtist(artist : String) -> String {
    
        var urlStr = "http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=\(artist)&\(LastFMAPIKey)api_key=b7361363b0bb6585af3095912ad3f7f5&format=json"
        
        urlStr = urlStr.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        
        let url = NSURL(string: urlStr)!
        let request = NSURLRequest(URL: url)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
            (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in

            var jsonError: NSError?
            var json = NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments, error: &jsonError) as NSDictionary
            
            if jsonError != nil {
                println("Error in JSON: \(jsonError)")
                gVideos.State = .NotAvailable
                gVideos.NeedsRefresh = true
                return
            }
            
            var parsedJson = JSONValue(json)
            println(parsedJson)

        })
        
        return ""
       
    }
}
