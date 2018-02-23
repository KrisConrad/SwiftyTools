//
//  NotificationTokenHandling.swift
//
//  Created by Kristopher Conrad on 2/6/18.
//  Copyright © 2018 Kristopher Conrad. All rights reserved.
//

import UIKit

/// A protocol for handling Notification Observation tokens (closure based observing)
protocol NotificationCenterTokenHandling: AnyObject {
    var tokens: [NSObjectProtocol] { get set }
    func unregisterNotificationTokens()
    func register(forName name: Notification.Name, using comletion: @escaping (Notification) -> Void)
}

extension NotificationCenterTokenHandling {
    /// adds an observer to the notification center for the passed in notification name
    /// executes the passed in closure on the main thread and manages the token
    func register(forName name: Notification.Name, using comletion: @escaping (Notification) -> Void) {
        let token = NotificationCenter.default.addObserver(forName: name,
                                                           object: nil,
                                                           queue: .main,
                                                           using: comletion)
        tokens.append(token)
    }

    /// Unregisters all notification tokens with the Notification Center
    func unregisterNotificationTokens() {
        for aToken in tokens {
            NotificationCenter.default.removeObserver(aToken)
        }
        tokens = []
    }
}
