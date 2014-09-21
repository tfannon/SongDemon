//
//  RootController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 7/29/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit

class RootController: UIPageViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    
    var mainController: UIViewController!
    var lyricsController: UIViewController!
    var playlistController: UITableViewController!
    var videoController: UITableViewController!
    var playVideoController: UIViewController!
    var controllers : [UIViewController] = []
    
       
    override func viewDidLoad() {
        super.viewDidLoad()

        self.delegate = self;
        self.dataSource = self;

        mainController = self.storyboard!.instantiateViewControllerWithIdentifier("MainController") as UIViewController
        lyricsController = self.storyboard!.instantiateViewControllerWithIdentifier("LyricsController") as UIViewController
        playlistController = self.storyboard!.instantiateViewControllerWithIdentifier("PlaylistController") as UITableViewController
        videoController = self.storyboard!.instantiateViewControllerWithIdentifier("VideoListController") as UITableViewController
        playVideoController = self.storyboard!.instantiateViewControllerWithIdentifier("PlayVideoController") as UIViewController

        controllers = [playlistController, mainController, lyricsController, videoController, playVideoController]

        //set the initial controller to the main one
        let viewControllers : [UIViewController] = [mainController]
        self.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
    }
    
    override func shouldAutorotate() -> Bool {
        return false
    }
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Page View Controller Data Source
    func presentationCountForPageViewController(pageViewController: UIPageViewController!) -> Int {
        return controllers.count
    }

    func presentationIndexForPageViewController(pageViewController: UIPageViewController!) -> Int {
        return 1    }


    //get the controller before the current one displayed
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController : UIViewController) -> UIViewController? {
        var index = find(controllers, viewControllerBeforeViewController)!
        if index == 0  {
            return nil
        }
        index--
        return controllers[index]
    }

    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController : UIViewController) -> UIViewController? {
        var index = find(controllers, viewControllerAfterViewController)!
        index++
        if index == controllers.count {
            return nil
        }
        return controllers[index]
    }
    
    class func switchToMainView() {
        var app = UIApplication.sharedApplication().keyWindow.rootViewController as RootController
        let viewControllers : [UIViewController] = [app.mainController]
        app.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
    }
    
    class func switchToVideoListController() {
        var app = UIApplication.sharedApplication().keyWindow.rootViewController as RootController
        let viewControllers : [UIViewController] = [app.videoController]
        app.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
    }
    
    class func switchToPlayVideoController() {
        var app = UIApplication.sharedApplication().keyWindow.rootViewController as RootController
        let viewControllers : [UIViewController] = [app.playVideoController]
        app.setViewControllers(viewControllers, direction: .Forward, animated: false, completion: {done in })
    }
    
    class func getPlayVideoController() -> PlayVideoController {
        var root = UIApplication.sharedApplication().keyWindow.rootViewController as RootController
        return root.playVideoController as PlayVideoController
    }
    
    class func getLyricsController() -> LyricsController {
        var root = UIApplication.sharedApplication().keyWindow.rootViewController as RootController
        return root.lyricsController as LyricsController
    }
}
