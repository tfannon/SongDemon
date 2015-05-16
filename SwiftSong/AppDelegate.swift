//
//  AppDelegate.swift
//  SwiftSong
//
//  Created by Tommy Fannon on 6/18/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
                            
    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        setupAppearance()
        FBLoginView.self
        
        Async.background {
            LibraryManager.scanLibrary()
        }
        
        return true
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
        var wasHandled = FBAppCall.handleOpenURL(url, sourceApplication: sourceApplication)
        return wasHandled
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        println("entering background")
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        FBAppEvents.activateApp()
        FBAppCall.handleDidBecomeActive()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        //LibraryManager.serializeCurrentPlaylist()
        FBSession.activeSession().close()
    }
    
    func setupAppearance() {
        UISlider.appearance().thumbTintColor = UIColor.redColor()
        UISlider.appearance().setThumbImage(UIImage(named:"pentagram.png"), forState: UIControlState.Normal)
        UISlider.appearance().setMaximumTrackImage(UIImage(named: "slider_maximum.png"), forState: .Normal)
        UISlider.appearance().setMinimumTrackImage(UIImage(named: "slider_minimum.png"), forState: .Normal)
        UIApplication.sharedApplication().statusBarStyle = UIStatusBarStyle.LightContent
    }
    
    
    func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
        
        var bgTask : UIBackgroundTaskIdentifier = UIBackgroundTaskInvalid
        
        bgTask = UIApplication.sharedApplication().beginBackgroundTaskWithName("bgtask") {
            bgTask = UIBackgroundTaskInvalid
        }
        
        println("received a call from watch")
        if let action = userInfo?["action"] as? String {
            switch (action) {
            case WK_LIKED_PLAYLIST, WK_MIX_PLAYLIST : LibraryManager.generatePlaylistsForWatch(true)
            case WK_ARTIST_PLAYLIST :
                if let artist = userInfo?["artist"] as? String {
                    let ids = LibraryManager.getArtistPlaylistForWatch(artist, regenerate: false)
                    reply(["ids":ids])
                }
            default :""
            }
        }
        reply(nil)
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2.0 * Float(NSEC_PER_SEC))), dispatch_get_main_queue()) {
                UIApplication.sharedApplication().endBackgroundTask(bgTask)
        }
    }
    
}

