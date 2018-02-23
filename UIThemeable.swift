//
//  UIThemeable.swift
//
//  Created by Kristopher Conrad on 1/28/18.
//  Copyright © 2018 Kristopher Conrad. All rights reserved.
//

import UIKit

let kUserSelectedTheme = "kUserSelectedTheme"

//MARK: -

/// The type used for theme names
enum UITheme: String {
    /// The light theme, with light backgrounds and dark text (default)
    case light
    /// The dark theme, with dark backgrounds and light text. aka 'night mode'
    case dark

    /// Private stored property so the current theme doens't have to be read from disk each time
    private static var _current: UITheme?

    /**
     The currently select user interface theme. Setting this will trigger userThemeSelectionDidChange(_:)
     calls to objects that conform to UIThemeable.
     */
    static var current: UITheme {
        set {
            //ignore if the theme didn't actually change
            guard newValue != _current else { return }

            //Update the user's selection
            _current = newValue
            UserDefaults.standard.set(newValue.rawValue, forKey: kUserSelectedTheme)
            UserDefaults.standard.synchronize()

            //post a notification for Themeable objects
            NotificationCenter.default.post(name: .ThemeDidChange, object: newValue.rawValue)
        }
        get {
            //if _current is nil we'll need to pull the saved theme out of UserDefaults or use the default value
            guard let current = _current else {
                var theme: UITheme = .light
                if let themeRaw = UserDefaults.standard.string(forKey: kUserSelectedTheme),
                    let savedTheme = UITheme(rawValue: themeRaw) {
                    theme = savedTheme
                }
                return theme
            }

            return current
        }
    }
}

//MARK: -
extension NSNotification.Name {
    static let ThemeDidChange = NSNotification.Name(rawValue: "kThemeDidChange")
}

//MARK: -

///Protocol for objects who wish to respond to user interface theme changes
protocol UIThemeable: NotificationCenterTokenHandling {
    /// Notifies the object that the user's theme selection has changed
    func userThemeSelectionDidChange(_ theme: UITheme)
}

//MARK: -
extension UIThemeable where Self: UIResponder {

    /// Registers for theme change notifications and immediately calls `userThemeSelectionDidChange(_:)`
    func registerForThemeNotifications() {
        
        let themeChange: (Notification) -> Void = { _ in
            self.userThemeSelectionDidChange(UITheme.current)
        }

        register(forName: .ThemeDidChange, using: themeChange)

        userThemeSelectionDidChange(UITheme.current)
    }
}
