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
    var Url : NSURL! = nil
    var NeedsRefresh = true

    class func fetchUrlFor(item: MPMediaItem?) {
        gLyrics.State = .Fetching
        
        if Utils.inSimulator() {
            gLyrics.NeedsRefresh = true
            gLyrics.Url = NSURL.URLWithString("http://www.darklyrics.com/lyrics/goatwhore/carvingouttheeyesofgod.html#7")
            return
        }
        if item != nil && item!.artist != nil && item!.albumArtist != nil {
            var artist = item!.albumArtist.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByReplacingOccurrencesOfString(" ", withString: "", options: .LiteralSearch, range: nil)
            var album = item!.albumTitle.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()).stringByReplacingOccurrencesOfString(" ", withString: "", options: .LiteralSearch, range: nil)
            var track = String(item!.albumTrackNumber)
            var urlStr = "http://www.darklyrics.com/lyrics/\(artist)/\(album).html#\(track)"
            //println(urlStr)
            gLyrics.Url = NSURL.URLWithString(urlStr)
            gLyrics.State = .Available
        } else {
            gLyrics.Url = nil
            gLyrics.State = .NotAvailable
        }
        gLyrics.NeedsRefresh = true
    }
}
