//
//  KeyboardObserving.swift
//
//  Created by Kristopher Conrad on 2/6/18.
//  Copyright © 2018 Kristopher Conrad. All rights reserved.
//

import UIKit

protocol KeyboardObserving: NotificationCenterTokenHandling {
    func keyboardWillShow(_ notification: Notification)
    func keyboardWillHide(_ notification: Notification)
}

extension KeyboardObserving {
    func registerForKeyboardNotifications() {

        let willShow: (Notification) -> Void = { notification in
            self.keyboardWillShow(notification)
        }

        register(forName: .UIKeyboardWillShow, using: willShow)

        let willHide: (Notification) -> Void = { notification in
            self.keyboardWillHide(notification)
        }

        register(forName: .UIKeyboardWillHide, using: willHide)
    }
}
