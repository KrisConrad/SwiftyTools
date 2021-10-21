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
     func presentError(title: String, message: String, includePlanDetails: Bool, complete: (() -> Void)?)
 }

 extension UIViewController {
     func presentError(title: String, message: String, includePlanDetails: Bool = false, complete: (() -> Void)? = nil) {
         let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

         if includePlanDetails,
             let teamID = rootNavigationHandler?.teamDataManager?.teamID,
             let team = UserDataManager.shared.userTeam(withID: teamID) {

             let plans = UIAlertAction(title: "View Plans", style: .default) { (_) in
                 let teamInfoController = TeamInfoController.fromNib(withTeam: team)
                 teamInfoController.addCloseButton()
                 let navigationController = UINavigationController(rootViewController: teamInfoController)

                 self.present(navigationController, animated: true, completion: nil)
             }

             alert.addAction(plans)
         }

         let ok = UIAlertAction(title: "OK", style: .default) { (_) in
             complete?()
         }
         alert.addAction(ok)

         self.present(alert, animated: true, completion: nil)
     }
 }
