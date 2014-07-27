//
//  SearchController.swift
//  SwiftSong
//
//  Created by Tommy Fannon on 6/29/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit
import MediaPlayer

class SearchController: UIViewController, MPMediaPickerControllerDelegate {

    /*
    init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        // Custom initialization
    }*/

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        UITabBar.appearance().tintColor = UIColor.darkGrayColor()
        let mediaPicker = MPMediaPickerController(mediaTypes: .Music)
        mediaPicker.delegate = self
        mediaPicker.allowsPickingMultipleItems = true
        presentViewController(mediaPicker, animated: true, completion: {})
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        UITabBar.appearance().tintColor = UIColor.whiteColor()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

    /*
    // #pragma mark - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue?, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */
    
    /*
    MPMediaPickerControllerDelegate
    */
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems  mediaItems:MPMediaItemCollection) -> Void
    {
        let items = mediaItems.items as [MPMediaItem]
        gLibraryManager.addToPlaylist(items)
//        dispatch_async(dispatch_get_main_queue(), {
            let v = UIAlertView()
            v.title = "Title"
            v.message = "\(items.count) songs added."
            v.addButtonWithTitle("Ok")
            v.show()
  //      })
        self.tabBarController.selectedIndex = 0;
        self.dismissViewControllerAnimated(true, completion: {});
    }
    
    func mediaPickerDidCancel(mediaPicker: MPMediaPickerController) {
        tabBarController.selectedIndex = 0;
        self.dismissViewControllerAnimated(true, completion: {});
    }
}
