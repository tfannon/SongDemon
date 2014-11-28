//
//  SeachController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 11/27/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit

class SearchController: UITabBarController {

    @IBOutlet var btnCancel: UIButton!
    
    @IBAction func handleCancelClicked(sender: AnyObject) {
        //var root = UIApplication.sharedApplication().keyWindow!.rootViewController as RootController
        //presentViewController(root, animated: false, completion: nil)
        //RootController.switchToMainView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnCancel.center = self.tabBar.center
        self.view.addSubview(btnCancel)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  }
