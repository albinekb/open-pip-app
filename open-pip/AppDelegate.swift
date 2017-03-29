//
//  AppDelegate.swift
//  open-pip
//
//  Created by Albin Ekblom on 2017-03-29.
//  Copyright © 2017 Albin Ekblom. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    @IBOutlet var window: NSWindow!
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        cleanUp()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    func cleanUp () {
        let fileManager = FileManager.default
        let path = Bundle.main.bundlePath
        let filePath = "\(path)/error.log"
        
        if fileManager.fileExists(atPath: filePath) {
            do {
                try fileManager.removeItem(atPath: filePath)
            }
            catch let error as NSError {
                print("Ooops! Something went wrong: \(error)")
            }
        } else {
            print("no old error.log found")
        }
    }
    
}

