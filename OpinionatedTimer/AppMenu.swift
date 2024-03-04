//
//  AppMenu.swift
//  OpinionatedTimer
//
//  Created by zzada on 2/10/24.
//  Copyright © 2024 zzada. All rights reserved.
//

import OSLog
import SwiftUI
import UserNotifications

struct AppMenu: View {
    @Binding var isOn: Bool
    @State private var triggerDate = Date()
    @State private var timerString = "Choose a duration"
    @State private var timer = Timer.publish(every: 1000, on: .main, in: .common).autoconnect()

    let formatter = RelativeDateTimeFormatter()
    
    var body: some View {
        // with a little help from https://stackoverflow.com/a/63548861
        if isOn {
            Text("Timer finishes...")
        }
        Text(timerString)
            .onReceive(timer) { _ in
                if self.isOn {
                    timerString = formatter.localizedString(fromTimeInterval: Date.now.distance(to: triggerDate))
                }
            }
        if isOn {
            Divider()
        }
        Button("5 Minutes") { setTimer(minutes: 5) }
            .disabled(isOn)
        Button("25 Minutes") { setTimer(minutes: 25) }
            .disabled(isOn)
        Button("55 Minutes") { setTimer(minutes: 55) }
            .disabled(isOn)
        Divider()
        Button("Quit") {
            clearNotifications()
            NSApplication.shared.terminate(nil)
        }
    }
    
    func stopTimer() {
        self.timer.upstream.connect().cancel()
    }
    
    func startTimer() {
        if isOn {
            stopTimer()
        }
        
        self.timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
    
    func clearNotifications() {
        // Remove scheduled timers and notifications
        isOn = false
        stopTimer()
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func setTimer(minutes: Double = 1) {
        Logger().debug("Setting a timer for \(minutes) minutes")
        startTimer()
        
        // Create the notification content
        let content = UNMutableNotificationContent()
        content.title = "Time is up"
        content.body = "Your \(Int(minutes)) minute timer is done"
        content.sound = .default
        content.interruptionLevel = .timeSensitive
        
        // Set up the time trigger
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: minutes * 60,
                                                        repeats: false)
        triggerDate = trigger.nextTriggerDate()!
        
        // Create the request
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content,
                                            trigger: trigger)
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { error in
            if let error = error {
                print(error.localizedDescription)
                Logger().error("Notification request error: \(error.localizedDescription)")
                return
            }
        }
        
        isOn = true
        Timer.scheduledTimer(withTimeInterval: minutes * 60, repeats: false) { _ in
            self.isOn = false
            timerString = "Choose a duration"
        }
    }
}
