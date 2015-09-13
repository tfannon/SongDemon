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
        if !Utils.inSimulator && item == nil { return }
        
        gLyrics.State = .Fetching

        var query = "";
        if Utils.inSimulator {
            query = "goatwhore/carvingouttheeyesofgod.html#7"
        }
        else {
            //cant fetch lyrics without album artist and a title
            if item?.albumArtist != nil && item?.albumTitle != nil && item?.title != nil {
                let artist = item!.albumArtist!.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByReplacingOccurrencesOfString(" ", withString: "", options: .LiteralSearch, range: nil)
                let album = item!.albumTitle!.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByReplacingOccurrencesOfString(" ", withString: "", options: .LiteralSearch, range: nil)
                let track = String(item!.albumTrackNumber)
                query = "\(artist)/\(album).html#\(track)"
            }
            else {
                print("Not enough info available for lyric fetch")
                gVideos.State = .NotAvailable
                return
            }
        }
        
        let urlStr = "http://www.darklyrics.com/lyrics/\(query)"
        if gLyrics.CurrentUrl.isEmpty || gLyrics.CurrentUrl != urlStr {
            //println("Loading lyrics for: \(item!.songInfo)")
            gLyrics.State = .Available
            gLyrics.CurrentUrl = urlStr
            let vc = RootController.getLyricsController()
            vc.loadLyrics(urlStr)
        }
        else {
            print("using cached lyrics")
        }
    }
}
