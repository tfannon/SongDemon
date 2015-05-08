//
//  InterfaceController.swift
//  SongDemon WatchKit Extension
//
//  Created by Tommy Fannon on 5/4/15.
//  Copyright (c) 2015 crazy8dev. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet weak var prevButton: WKInterfaceButton!
    @IBAction func prevPressed() {
    }
    
    @IBOutlet weak var playButton: WKInterfaceButton!
    @IBAction func playPressed() {
    }
    
    @IBOutlet weak var nextButton: WKInterfaceButton!
    @IBAction func nextPressed() {
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        // Configure interface objects here.
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
