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


let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBar: NSStatusBar!
    var statusItem: NSStatusItem!
    let notificationCenter = UNUserNotificationCenter.current()
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        
        statusBar = NSStatusBar()
        statusItem = statusBar.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.menu = createMenu()
        
        if let button = statusItem.button {
            button.image = NSImage(named: "tomatoIcon")
            button.image?.isTemplate = true
            button.toolTip = "OpinionatedTimer \(appVersion ?? "")"
        }
        
        // Request user access if needed
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if error != nil {
                os_log("Notification permission error: %s", type: .error, error.debugDescription)
            }
        }
    }
    
    func createMenu() -> NSMenu {
        let menu = NSMenu()
        
        let fiveMins = NSMenuItem(title: "5 Minutes", action: #selector(setTimer), keyEquivalent: "")
        menu.addItem(fiveMins)
        
        let twentyFiveMins = NSMenuItem(title: "25 Minutes", action: #selector(setTimer), keyEquivalent: "")
        menu.addItem(twentyFiveMins)

        let fiftyFiveMins = NSMenuItem(title: "55 Minutes", action: #selector(setTimer), keyEquivalent: "")
        menu.addItem(fiftyFiveMins)
        
        menu.addItem(.separator())
        
        let quit = NSMenuItem(title: "Quit", action: #selector(quitClicked), keyEquivalent: "")
        menu.addItem(quit)
        
        return menu
    }
    
    @objc func setTimer(_ sender: NSMenuItem) {
        
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
        var success = true
        notificationCenter.add(request) { (error) in
            if error != nil {
                os_log("Notification request error: %s", type: .error, error.debugDescription)
                success = false
            }
        }
        
        if success {
            statusItem.button?.image = NSImage(named: "filledTomato")
            statusItem.button?.image?.isTemplate = false
            
            Timer.scheduledTimer(withTimeInterval: time * 60, repeats: false) { _ in
                self.statusItem.button?.image = NSImage(named: "tomatoIcon")
                self.statusItem.button?.image?.isTemplate = true
            }
        }
    }
    
    // Quit
    @objc func quitClicked(_sender: NSMenuItem) {
        NSApplication.shared.terminate(self)
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Remove scheduled timers
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
}
