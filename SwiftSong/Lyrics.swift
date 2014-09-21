import MediaPlayer

let gLyrics = Lyrics()

enum LyricState {
    case Available
    case Displayed
    case NotAvailable
    case Fetching
}

class Lyrics {
    
    var State = LyricState.Fetching
    var CurrentUrl = ""

    class func fetchUrlFor(item: MPMediaItem?) {
        gLyrics.State = .Fetching

        var query = "";
        if Utils.inSimulator {
            query = "goatwhore/carvingouttheeyesofgod.html#7"
        }
        else {
            //cant fetch lyrics without album artist and a title
            if item?.albumArtist != nil && item?.albumTitle != nil && item?.title != nil {
                var artist = item!.albumArtist.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByReplacingOccurrencesOfString(" ", withString: "", options: .LiteralSearch, range: nil)
                var album = item!.albumTitle.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByReplacingOccurrencesOfString(" ", withString: "", options: .LiteralSearch, range: nil)
                var track = String(item!.albumTrackNumber)
                query = "\(artist)/\(album).html#\(track)"
            }
            else {
                println("Not enough info available for lyric fetch")
                gVideos.State = .NotAvailable
                return
            }
        }
        
        var urlStr = "http://www.darklyrics.com/lyrics/\(query)"
        
        if gLyrics.CurrentUrl.isEmpty || gLyrics.CurrentUrl != urlStr {
            //println("Loading lyrics for: \(query)")
            
            RootController.getLyricsController().loadAddressUrl(urlStr)
            gLyrics.State = .Available

            /*
            let url = NSURL.URLWithString(urlStr)
            let request = NSURLRequest(URL: url)
            
            NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: {
                (response: NSURLResponse!, data: NSData!, error: NSError!) -> Void in

                if error != nil {
                    println("Error in lyrics fetch Connection: \(error)")
                    println()
                    gLyrics.State = .NotAvailable
                    return
                }
                gLyrics.State = .Available
                RootController.getLyricsController().myWeb.loadData(data, MIMEType: "text/html", textEncodingName: "UTF-8", baseURL: nil)
            })
            */
        } else {
            println("using cached lyrics")
        }
    }
}
