//
//  UIHelpers.swift
//  SwiftSong
//
//  Created by Tommy Fannon on 7/9/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import Foundation
import UIKit


class UIHelpers  {
    class func messageBox(title:String, message:String = "") {
        let v = UIAlertView()
        v.title = title
        v.message = message
        v.addButtonWithTitle("Ok")
        v.show()
    }
}