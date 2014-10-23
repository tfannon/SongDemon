//
//  FacebookUtils.swift
//  SongDemon
//
//  Created by Tommy Fannon on 9/27/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

let FacebookSuccess = "Posted to Facebook"
let FacebookFailure = "Problem posting to Facebook"

class FacebookUtils {
   
  
    class func post(artist:String, title:String, artworkUrl:String, videoUrl:String, callback: (String) -> ()) {
        let useNativeShare = FBDialogs.canPresentShareDialog()
        let perms = ["publish_actions"]
        let state = FBSession.activeSession().state
        if state == FBSessionState.CreatedTokenLoaded {
            publish(artist, title: title, artworkUrl: artworkUrl, videoUrl: videoUrl, nativeCall: useNativeShare, callback: callback)
        }
        else {
            FBSession.openActiveSessionWithPublishPermissions(perms, defaultAudience: FBSessionDefaultAudience.Everyone, allowLoginUI: true, completionHandler: { (session, status, error) in
                if !session.isOpen {
                    UIHelpers.messageBox(message: FacebookFailure)
                    return
                }
                self.publish(artist, title: title, artworkUrl: artworkUrl, videoUrl: videoUrl, nativeCall: useNativeShare, callback: callback)
            })
        }
    }
    
    private class func publish(artist:String, title:String, artworkUrl:String?, videoUrl:String?, nativeCall : Bool, callback: (String) -> ()) {
        
        var artworkNSUrl = NSURL(string: artworkUrl!)
        var videoNSUrl = NSURL(string: videoUrl!)
        var message = "I am listening to \(title) by \(artist)"
        var parms = FBLinkShareParams()
        parms.name = message
        parms.picture = artworkNSUrl
        parms.link = videoNSUrl
        
        if nativeCall {
            FBDialogs.presentShareDialogWithLink(videoNSUrl, name: message, caption: "", description: "", picture: artworkNSUrl, clientState: nil, handler: {(call, results, error) in
                if error != nil {
                    UIHelpers.messageBox(message: FacebookFailure)
                } else {
                    callback(FacebookSuccess)
                }
            })
        }
        else {
            var params =
                ["name":  message,
                 "link":  videoUrl!,
                 "picture":  artworkUrl!] as NSMutableDictionary
            
        FBWebDialogs.presentFeedDialogModallyWithSession(FBSession.activeSession(), parameters: params, handler: {(results, resultUrl, error) in
                if error != nil {
                    UIHelpers.messageBox(message: FacebookFailure)
                } else {
                    callback(FacebookSuccess)
                }
            })
        }
    }
}