//
//  AppDelegate.swift
//  OpinionatedTimer
//
//  Created by zzada on 1/10/20.
//  Copyright © 2020 zzada. All rights reserved.
//

import OSLog
import Cocoa
import UserNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var statusMenu: NSMenu!
    let notificationCenter = UNUserNotificationCenter.current()
    let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        // Set the icon
        let icon = NSImage(named: "tomatoIcon")
        icon?.isTemplate = true // inverts in dark mode
        statusItem.button?.image = icon        
        statusItem.menu = statusMenu
        
        // Request user access if needed
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if error != nil {
                os_log("Notification permission error: %s", type: .error, error.debugDescription)
            }
        }
    }

    @IBAction func setTimer(_ sender: NSMenuItem) {

        // Determine time interval
        var time: Double = 1
        if sender.title == "5 Minutes" {
            time = 5
        }
        else if sender.title == "25 Minutes" {
            time = 25
        }
        else if sender.title == "55 Minutes" {
            time = 55
        }
        
        os_log("Setting a timer for %d minutes", type: .info, Int(time))
      
        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "Time is up"
        content.body = "Your " + sender.title + " timer is done"
        content.sound = UNNotificationSound.default
        
        // Set up the time trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: time * 60, repeats: false)
        
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                    content: content, trigger: trigger)

        // Schedule the request with the system.
        notificationCenter.add(request) { (error) in
           if error != nil {
            os_log("Notification request error: %s", type: .error, error.debugDescription)
           }
        }
    }

    // Quit
    @IBAction func quitClicked(sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Remove scheduled timers
        notificationCenter.removeAllPendingNotificationRequests()
    }

}
