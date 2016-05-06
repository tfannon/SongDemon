//
//  RootController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 7/29/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit

class RootController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var mainController: MainController!
    var lyricsController: UIViewController!
    var playlistController: UITableViewController!
    var videoController: UITableViewController!
    var playVideoController: UIViewController!
    var controllers : [UIViewController] = []
    var currentIndex = 1
    
    

    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self;
        self.dataSource = self;

        mainController = self.storyboard!.instantiateViewControllerWithIdentifier("MainController") as! MainController
        lyricsController = self.storyboard!.instantiateViewControllerWithIdentifier("LyricsController") 
        playlistController = self.storyboard!.instantiateViewControllerWithIdentifier("PlaylistController") as! UITableViewController
        videoController = self.storyboard!.instantiateViewControllerWithIdentifier("VideoListController") as! UITableViewController
        playVideoController = self.storyboard!.instantiateViewControllerWithIdentifier("PlayVideoController") 

        controllers = [playlistController, mainController, lyricsController, videoController, playVideoController]

        //set the initial controller to the main one
        let viewControllers : [UIViewController] = [mainController]
        self.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
        
        findScrollView()
        
        LibraryManager.addListener(self.mainController)
    }
    
    //  this will allow the slider to interpret the touch events and NOT pass them onto the underlying scroll view.  without this, the user is required to hold the slider to activate it before scrolling
    func findScrollView() {
        for x in self.view.subviews {
            if x.isKindOfClass(UIScrollView) {
                let scrollView = x as! UIScrollView
                scrollView.delaysContentTouches = false
            }
        }
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
  
    
    // MARK: - Page View Controller Data Source
    func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
        return controllers.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
        return currentIndex
    }


    //get the controller before the current one displayed
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController : UIViewController) -> UIViewController? {
        var index = controllers.indexOf(viewControllerBeforeViewController)!
        if index == 0  {
            return nil
        }
        index--
        return controllers[index]
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController : UIViewController) -> UIViewController? {
        var index = controllers.indexOf(viewControllerAfterViewController)!
        index++
        if index == controllers.count {
            return nil
        }
        return controllers[index]
    }
    
    class func switchToMainView() {
        let root = UIApplication.sharedApplication().keyWindow!.rootViewController as! RootController
        root.currentIndex = 1
        let viewControllers : [UIViewController] = [root.mainController]
        root.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
    }
    
    /*
    class func switchToVideoListController() {
        var app = UIApplication.sharedApplication().keyWindow.rootViewController as RootController
        let viewControllers : [UIViewController] = [app.videoController]
        app.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
    }
    */
    
    class func switchToPlayVideoController() {
        let root = UIApplication.sharedApplication().keyWindow!.rootViewController as! RootController
        root.currentIndex = 4
        let viewControllers : [UIViewController] = [root.playVideoController]
        root.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
    }
    
    class func getPlayVideoController() -> PlayVideoController {
        let root = UIApplication.sharedApplication().keyWindow!.rootViewController as! RootController
        return root.playVideoController as! PlayVideoController
    }
    
    class func getLyricsController() -> LyricsController {
        let root = UIApplication.sharedApplication().keyWindow!.rootViewController as! RootController
        return root.lyricsController as! LyricsController
    }
    
    class func getPlaylistController() -> PlaylistController {
        let root = UIApplication.sharedApplication().keyWindow!.rootViewController as! RootController
        return root.playlistController as! PlaylistController
    }
}
