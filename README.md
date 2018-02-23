# SwiftyTools
A collection of stuff I use often in my projects

# Error Presenting
Auto-Conforming Protocol UIViewControllers for easily and quickly presenting simple error messages.
Error messages are presented in UIAlertController with a single "OK" button that dismisses the alert.

###### Example:
```
class SomeViewController: UIViewController, ErrorPresenting {
  func someFunction() {
    thing.someAsyncTask() { error in
      self.presentError(title: "OH NOES!",
                        message: error.localizedDescription)
    }
  }
}
```

# NotificationTokenHandling
A protocol for handling Notification Observation tokens (closure based observing). Makes the Notification Center feel more Swifty.

###### Example:
```
  // Register for some Notification
  override func viewDidLoad() {
    let willShow: (Notification) -> Void = { notification in
           self.keyboardWillShow(notification)
       }

      register(forName: .UIKeyboardWillShow, using: willShow)
  }

  // Unregister Notification tokens
  deinit {
    unregisterNotificationTokens()
  }
```

# KeyboardObserving
Simple protocol to get rid of the repetitive boilerplate generally used to observe presenting and dismissing of the keyboard.

Requires `NotificationTokenHandling`

###### Example:
```
  // Register for theme change notifications
  override func viewDidLoad() {
    registerForKeyboardNotifications()
  }

  // Unregister Notification tokens
  deinit {
    unregisterNotificationTokens()
  }
  
extension ChatRoomController: KeyboardObserving {
  func keyboardWillShow(_ notification: Notification) {
    // Adjust view to account for keyboard covering part of the screen
    ...
  }

  func keyboardWillHide(_ notification: Notification) {
    // Adjust view back
    ...
  }
}
```

# UIThemeable
A protocol for easy user interface theme changes.

Requires `NotificationTokenHandling`

###### Example:
```
  // Register for theme change notifications
  override func viewDidLoad {
    registerForThemeNotifications()
  }

  // Unregister Notification tokens
  deinit {
    unregisterNotificationTokens()
  }

extension ChatRoomController: UIThemeable {
   func userThemeSelectionDidChange(_ theme: UITheme) {
     view.backgroundColor = theme == .light ? .white : .black
     // theme stuff here
     ...
   }
}
```
