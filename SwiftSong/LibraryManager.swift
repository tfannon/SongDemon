
import MediaPlayer

let LIKED_LIST = "Liked"
let DISLIKED_LIST = "Disliked"
private let LM = LibraryManager()

class LibraryManager {
    
    final var LikedSongs = Dictionary<String, String>()
    final var DislikedSongs = Dictionary<String, String>()
    

    init() {
        println("storage objects being initialized from NSDefaults")
        let userDefaults = NSUserDefaults.standardUserDefaults();
        if let result = userDefaults.objectForKey(LIKED_LIST) as? Dictionary<String,String> {
            //println("all liked songs: \(result)")
            //construct the liked songs from the defaults
            for (x,y) in result {
               LikedSongs[x] = y
               println("\(x):\(y)")
            }
        }
        if let result = userDefaults.objectForKey(DISLIKED_LIST) as? Dictionary<String,String> {
            println("all disliked songs: \(result)")
            //construct the disliked songs from the defaults
            for (x,y) in result {
                DislikedSongs[x] = y
            }
        }
    }

    class func addToLiked(item:MPMediaItem) {
        addToList(LIKED_LIST, list: &LM.LikedSongs, item: item)
    }
    
    class func removeFromLiked(item:MPMediaItem) {
        removeFromList(LIKED_LIST, list: &LM.LikedSongs, item: item)
    }
    
    class func addToDisliked(item:MPMediaItem) {
        addToList(DISLIKED_LIST, list: &LM.DislikedSongs, item: item)
        //adding it to disliked will remove it from liked
        removeFromLiked(item)
    }
    
    private class func addToList(listName:String, inout list:Dictionary<String,String>, item:MPMediaItem) {
        if (item != nil) {
            list[getHashKey(item)] = item.title
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(list, forKey: listName)
            //println(item.songInfo)
             //dumpNSUserDefaults(LIKED_LIST)
        }
    }
    
    private class func removeFromList(listName:String, inout list:Dictionary<String,String>, item:MPMediaItem) {
        if (item != nil) {
            list.removeValueForKey(getHashKey(item));
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.setObject(list, forKey: listName)
        }
    }
    
    private class func getHashKey(item:MPMediaItem) -> String {
        return item.persistentID.description
    }

    class func addToPlaylist(items:[MPMediaItem]) -> Void {
        for item in items {
           LM.LikedSongs[getHashKey(item)] = item.title
        }
        let userDefaults = NSUserDefaults.standardUserDefaults()
        userDefaults.setObject(LM.LikedSongs, forKey: LIKED_LIST)
        println ("added \(items.count) songs")
        //dumpNSUserDefaults(LIKED_LIST)
    }
    
    class func isLiked(item:MPMediaItem) -> Bool {
        if item != nil {
            if let oldSong = LM.LikedSongs[getHashKey(item)] {
                return true;
            }
        }
        return false;
    }
    
    func dumpNSUserDefaults(forKey:String) -> Void {
        println("Current dictionary: \(self.LikedSongs)")
        let userDefaults = NSUserDefaults.standardUserDefaults()
        if let songsFromDefaults = userDefaults.objectForKey(forKey) as? Dictionary<String,String> {
            println("Current defaults: \(songsFromDefaults)")
        } else {
            println("No userDefaults")
        }
    }
}
