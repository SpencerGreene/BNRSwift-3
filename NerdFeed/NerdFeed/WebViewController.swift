//
//  WebViewController.swift
//  NerdFeed
//
//  Created by Spencer Greene on 7/25/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
        
    var url: URL? = nil
    var popoverController: UIViewController? = nil
    
    func installURL(_ newURL: URL?) {
        self.url = newURL
        
        NSLog("WebViewController URL install operation called")
        if (newURL == nil) {
            NSLog("set to nil; bailing")
            return
        }
        
        let req = URLRequest(url: newURL!)
        let webView = self.view as! UIWebView
        webView.loadRequest(req)
        NSLog("loaded URL")
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func loadView() {
        let webView = UIWebView()
        webView.scalesPageToFit = true
        self.view = webView
        
    }
    
    func hideSplitPopover() {
        if (self.splitViewController != nil) {
            if let pc = self.popoverController {
                pc.dismiss(animated: true)
            }
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue!, sender: AnyObject!) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension WebViewController: UISplitViewControllerDelegate {
    /*
    func splitViewController(_ svc: UISplitViewController,
                             willHide aViewController: UIViewController,
                             with barButtonItem: UIBarButtonItem,
                             for pc: UIViewController) {
            
            // set title for the bar button item so that it can appear
            self.popoverController = pc
            barButtonItem.title = "Courses"
            
            // now put it on the left side of the nav
            self.navigationItem.leftBarButtonItem = barButtonItem
            
    }
   */
    
    func splitViewController(_ svc: UISplitViewController,
        willChangeTo displayMode: UISplitViewControllerDisplayMode) {
            
            // if we are changing to landscape with both views showing, then hide the button
            if (displayMode == UISplitViewControllerDisplayMode.allVisible) {
                self.navigationItem.leftBarButtonItem = nil
            }

    }
}

extension UISplitViewControllerDisplayMode {
    func describe() -> String {
        if (self == UISplitViewControllerDisplayMode.allVisible) { return "AllVisible" }
        if (self == UISplitViewControllerDisplayMode.primaryHidden) { return "PrimaryHidden" }
        return "Idunno"
    }
}
