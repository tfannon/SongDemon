//
//  FacebookUtils.swift
//  SongDemon
//
//  Created by Tommy Fannon on 9/27/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

class FacebookUtils {
    
    class func post(artist:String, title:String, artworkUrl:String, videoUrl:String) {
        let useNativeShare = FBDialogs.canPresentShareDialog()
        let perms = ["publish_actions"]
        let state = FBSession.activeSession().state
        if state == FBSessionState.CreatedTokenLoaded {
            publish(artist, title: title, artworkUrl: artworkUrl, videoUrl: videoUrl, nativeCall: useNativeShare)
        }
        else {
            FBSession.openActiveSessionWithPublishPermissions(perms, defaultAudience: FBSessionDefaultAudience.Everyone, allowLoginUI: true, completionHandler: { (session, status, error) in
                if !session.isOpen {
                    UIHelpers.messageBox(message: "problem posting to Facebook")
                    return
                }
                self.publish(artist, title: title, artworkUrl: artworkUrl, videoUrl: videoUrl, nativeCall: useNativeShare)
            })
        }
    }
    
    private class func publish(artist:String, title:String, artworkUrl:String?, videoUrl:String?, nativeCall : Bool) {
        var artworkNSUrl = NSURL.URLWithString(artworkUrl!)
        var videoNSUrl = NSURL.URLWithString(videoUrl!)
        var message = "I am listening to \(title) by \(artist)"
        var parms = FBLinkShareParams()
        parms.name = message
        //parms.description = "Click to watch the video"
        parms.picture = artworkNSUrl
        parms.link = videoNSUrl
        if nativeCall {
            FBDialogs.presentShareDialogWithParams(parms, clientState: nil, handler: {(call, results, error) in
                println(error)
            })
        }
        else {
            //do nothing without facebook app yet
        }
        

    }
}