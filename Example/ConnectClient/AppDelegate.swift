//
//  TPAppDelegate.swift
//  ConnectClient
//
//  Created by Chad Edrupt on 4/05/2015.
//  Copyright (c) 2015 Chad Edrupt. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        
        TPConnectClient.sharedClientWithAPIKey("2263ffe20c676cb90b1d9e2b2473fae9ae4b26a98542724677b23eb0a00e69e6")
        
        return true
    }
    
    
    func applicationDidEnterBackground(application: UIApplication) {
        
        if let connectClient = TPConnectClient.sharedClient() {
            connectClient.pushAllPendingEvents()
        }
        
    }
}