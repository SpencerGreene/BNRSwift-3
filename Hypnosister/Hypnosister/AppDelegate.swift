//
//  AppDelegate.swift
//  Hypnosister
//
//  Created by Spencer Greene on 6/28/14.
//  Copyright (c) 2014 babygreene.org. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UIScrollViewDelegate {
                            
    var window: UIWindow?
    var hypnosisView: HypnosisView?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        
        // Override point for customization after application launch.
        let screenRect = self.window!.bounds
        
        let scrollView = UIScrollView(frame:screenRect)
        scrollView.delegate = self
        // scrollView.pagingEnabled = true
        
        var bigRect = screenRect
        bigRect.size.width *= 2
        bigRect.size.height *= 2
        scrollView.contentSize = bigRect.size
        scrollView.minimumZoomScale = 0.2;
        scrollView.maximumZoomScale = 5.0;
        
        hypnosisView = HypnosisView(frame: bigRect)
        scrollView.addSubview(hypnosisView!)

        
        self.window!.addSubview(scrollView)
        
        self.window!.rootViewController = UIViewController()
        self.window!.rootViewController!.view = scrollView
        
        // auto-generated stuff below here
        self.window!.backgroundColor = UIColor.white
        self.window!.makeKeyAndVisible()
        return true
    }
    
    func viewForZoomingInScrollView(scroller: UIScrollView) -> UIView {
        NSLog("zoom called on %@", scroller)
        return self.hypnosisView!
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

