//
//  AppDelegate.swift
//  Codinator
//
//  Created by Vladimir Danila on 03/07/2016.
//  Copyright © 2016 Vladimir Danila. All rights reserved.
//

import UIKit
//import Fabric
//import Crashlytics


@UIApplicationMain
class AppDelegate: UIResponder , UIApplicationDelegate, FileManagerDelegate {

    var window: UIWindow?
    lazy var fileManager = FileManager.default
    
    class var storageURL: URL {
        get {
            let rootDirectory = try! FileManager.default.urlForUbiquityContainerIdentifier(nil)?.appendingPathComponent("Documents")
                
            if rootDirectory != nil && UserDefaults.standard.bool(forKey: "CnCloud") == true {
                return rootDirectory!
            }
            
            
            
            let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first
            let homeURL = URL(fileURLWithPath: documentDirectory!, isDirectory: true)
            
            return homeURL
        }
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

//        Fabric.with([Crashlytics.self])
        
        
        // Create FileSystem
        let path = (NSHomeDirectory() as NSString).appendingPathComponent("Documents")
        let url = URL(fileURLWithPath: path, isDirectory: true)
        
        do {
            let playgroundsURL = try url.appendingPathComponent("Playgrounds")
            let projectsURL = try url.appendingPathComponent("Projects")

            
            try fileManager.createDirectory(at: playgroundsURL, withIntermediateDirectories: false, attributes: nil)
            try fileManager.createDirectory(at: projectsURL, withIntermediateDirectories: false, attributes: nil)
            
            let rootDirectory = try fileManager.urlForUbiquityContainerIdentifier(nil)?.appendingPathComponent("Documents")


            try fileManager.setUbiquitous(true, itemAt: playgroundsURL, destinationURL: rootDirectory!.appendingPathComponent("Playgrounds"))
            try fileManager.setUbiquitous(true, itemAt: projectsURL, destinationURL: rootDirectory!.appendingPathComponent("Projects"))
            
        } catch {}
      
        
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [String : AnyObject] = [:]) -> Bool {
        return self.moveImported(filename: url.lastPathComponent!, at: url)
    }
    
    // MARK: - Hand off
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: ([AnyObject]?) -> Void) -> Bool {
        
        let navController = self.window?.rootViewController as! UINavigationController
        let welcomeViewController = navController.viewControllers.first as! WelcomeViewController
        
        welcomeViewController.restoreUserActivityState(userActivity)
        
        return true
    }
    
    
    // MARK: - File imports
    
    func moveImported(filename: String, at url: URL) -> Bool {
        
        // Get storage path
        let storagePath = AppDelegate.storageURL.path
        
        // Check if dir exists
        if fileManager.fileExists(atPath: storagePath!) {
            
            // Move file to location
            do {
                try fileManager.moveItem(at: url, to: URL(fileURLWithPath: storagePath!, isDirectory: true).appendingPathComponent(filename))
                
                let navController = self.window?.rootViewController as! UINavigationController
                let welcomeViewController = navController.viewControllers.first as! WelcomeViewController
                
                welcomeViewController.reloadData()
                
            } catch {
                print("error: \(error)")
            }
            
            
        }
        
        return false
    }

    
    
    
    
    // MARK: - Others
    
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
