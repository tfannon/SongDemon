//
//  NoAnimationSegue.swift
//  SongDemon
//
//  Created by Tommy Fannon on 11/27/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit

class NoAnimationSegue: UIStoryboardSegue {
    
    override func perform() {
        let source = sourceViewController as! UIViewController
        source.presentViewController(destinationViewController as! UIViewController, animated: false, completion: nil)
//        if let navigation = source.navigationController {
//            navigation.pushViewController(destinationViewController as UIViewController, animated: false)
//        }
    }
}