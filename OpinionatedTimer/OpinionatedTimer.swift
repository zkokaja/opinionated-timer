//
//  AppDelegate.swift
//  OpinionatedTimer
//
//  Created by zzada on 1/10/20.
//  Copyright © 2020 zzada. All rights reserved.
//

import OSLog
import SwiftUI
import UserNotifications

@main
struct OpinionatedTimer: App {
    @State private var isOn: Bool = false

    init() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            if error != nil {
                Logger().error("Notification permission error: \(error.debugDescription)")
            }
        }
    }

    var body: some Scene {
        MenuBarExtra("Opinionated Timer",
                     image:isOn ? "filledTomato" : "tomatoIcon") {
            AppMenu(isOn: $isOn)
        }
    }
}
