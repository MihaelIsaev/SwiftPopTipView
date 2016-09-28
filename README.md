# SwiftPopTipView

The representation of CMPopTipView in Swift

![iPhone screenshot](https://farm8.staticflickr.com/7497/15865951110_8e30e1780e.jpg)

An iOS UIView subclass that displays a rounded rect "bubble", containing
a text message, pointing at a specified button or view.

A SwiftPopTipView will automatically position itself within the view so that
it is pointing at the specified button or view, positioning the "pointer"
as necessary.

A SwiftPopTipView can be pointed at any UIView within the containing view.
It can also be pointed at a UIBarButtonItem within either a UINavigationBar
or a UIToolbar and it will automatically position itself to point at the
target.

The background and text colors can be customised if the defaults are not
suitable.

Two animation options are available for when a SwiftPopTipView is presented:
"slide" and "pop".

A SwiftPopTipView can be dismissed by the user tapping on it.  It can also
be dismissed programatically.

SwiftPopTipView is rendered entirely by Core Graphics.

The source includes a universal (iPhone/iPad) demo app.

## URLs

 * https://github.com/chrismiles/CMPopTipView
 * http://mihaelisaev.com
 
## Requirements

* iOS 8.1+
* Xcode 8+

## Usage

Example 1 - point at a UIBarButtonItem in a nav bar::

``` swift
  // Present a SwiftPopTipView pointing at a UIBarButtonItem in the nav bar
let navBarLeftButtonPopTipView = SwiftPopTipView(message: "A message")
navBarLeftButtonPopTipView.presentPointingAtBarButtonItem(navigationItem.leftBarButtonItem!, animated: true)
  
  // Dismiss a SwiftPopTipView
  navBarLeftButtonPopTipView.dismissAnimated(true)
  
```

Example 2 - pointing at a UIButton, with custom color scheme::

``` swift
class ViewController: UIViewController, SwiftPopTipViewDelegate {
    var roundRectButtonPopTipView: SwiftPopTipView?

    @IBAction func buttonAction(_ sender: UIButton) {
        // Toggle popTipView when a standard UIButton is pressed
        if let _ = roundRectButtonPopTipView {
            // Dismiss
            roundRectButtonPopTipView?.dismissAnimated(true)
            roundRectButtonPopTipView = nil
        } else {
            roundRectButtonPopTipView = SwiftPopTipView(message: "My message")
            roundRectButtonPopTipView?.delegate = self
            roundRectButtonPopTipView?.popColor = UIColor.lightGray
            roundRectButtonPopTipView?.textColor = UIColor.darkText

            roundRectButtonPopTipView?.presentPointingAtView(sender as! UIView, containerView: view, animated: true)
        }
    }

    //MARK: - SwiftPopTipViewDelegate methods
    func popTipViewWasDismissedByUser(popTipView: SwiftPopTipView) {
        // User can tap SwiftPopTipView to dismiss it
        roundRectButtonPopTipView = nil
    }
}
```

## Support

SwiftPopTipView is provided open source with no warranty and no guarantee
of support. However, best effort is made to address issues raised on Github
https://github.com/MihaelIsaev/SwiftPopTipView/issues

If you would like assistance with integrating SwiftPopTipView or modifying
it for your needs, contact the author <me@mihaelisaev.com> for consulting
opportunities.


## License

SwiftPopTipView is Copyright (c) 2014 MihaelIsaev (mihaelisaev.com) and released open source
under a MIT license:

    Permission is hereby granted, free of charge, to any person obtaining a copy
    of this software and associated documentation files (the "Software"), to deal
    in the Software without restriction, including without limitation the rights
    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
    copies of the Software, and to permit persons to whom the Software is
    furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included in
    all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
    THE SOFTWARE.
