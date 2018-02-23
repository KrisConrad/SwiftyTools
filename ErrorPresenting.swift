//
//  ErrorPresenting.swift
//
//  Created by Kristopher Conrad on 2/5/18.
//  Copyright © 2018 Kristopher Conrad. All rights reserved.
//

import UIKit
/**
 Auto-Conforming Protocol UIViewControllers for easily and quickly presenting simple error messages.
 Error messages are presented in UIAlertController with a single "OK" button that dismisses the alert.
 */
protocol ErrorPresenting {
    ///Presents a simple, dismissable alert to the user with the provided title and message
    func presentError(title: String, message: String)
}

extension ErrorPresenting where Self: UIViewController {
    func presentError(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}
