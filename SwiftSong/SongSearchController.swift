//
//  SongSearchController.swift
//  SongDemon
//
//  Created by Tommy Fannon on 11/15/14.
//  Copyright (c) 2014 crazy8dev. All rights reserved.
//

import UIKit

class SongSearchController: UIViewController, UITableViewDataSource, UITabBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var tabBar: UITabBar!
    
    let cellId = "SearchArtistCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tabBar.selectedItem = tabBar.items![1] as? UITabBarItem
        //todo: remember what is was last time?
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellId, forIndexPath: indexPath)
            as SearchArtistCell
        cell.lblArtist.text = "Goatwhore"
        cell.lblInformation.text = "10 Albums"
        return cell
    }
    
    //MARK: UITabBarDelegate
    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem!) {
        //println(item)
        switch item.title! {
        case "Cancel" :
            self.dismissViewControllerAnimated(false, completion: nil)
        default:
            println(item)
        }
    }
    

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
