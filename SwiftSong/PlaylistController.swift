//
//  PlaylistController.swift
//  SwiftSong
//
//  Created by Tommy Fannon on 7/13/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit

class PlaylistController: UIViewController, UIActionSheetDelegate {

    //MARK:Controller overloads
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func viewDidAppear(animated: Bool) {
        var alert = UIAlertController(title: "Choose playlist", message: nil, preferredStyle: UIAlertControllerStyle.ActionSheet)
        //style: default is blue, destructive is red, cancel is a seperate cancel button
        alert.addAction(UIAlertAction(title: "Mix", style: .Default, handler: { action in
            switch action.style{
            case .Default:
                println("default")
                break
                
            case .Cancel:
                println("cancel")
                break
                
            case .Destructive:
                println("destructive")
                break
            }}))

        //handler: ((UIAlertAction!) -> Void)!)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: {action in
            println("ok chosen")
        }))
        
        alert.addAction(UIAlertAction(title: "New", style: .Default, handler: { action in
            println("new chosen")
            }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { action in
            println("cancel chosen")
            }))

        //no matter what option is chosen switch the window back to main
        self.presentViewController(alert, animated: true, completion: {
             self.tabBarController.selectedIndex = 0;
            })
    }
}
