//
//  ViewController.swift
//  SwiftPopTipView
//
//  Created by Mihael Isaev on 18.12.14.
//  Copyright (c) 2014 Mihael Isaev inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setToolbarHidden(false, animated: false)
    }
    
    @IBAction func showPopTip(sender: AnyObject) {
        var popTip = SwiftPopTipView(title: "Hello!", message: "This is the test pop tip view!!!")
        popTip.popColor = UIColor(red: 63/255, green: 162/255, blue: 232/255, alpha: 1)
        popTip.titleColor = UIColor.whiteColor()
        popTip.textColor = UIColor.whiteColor()
        if sender.dynamicType === UIBarButtonItem.self {
            popTip.presentAnimatedPointingAtBarButtonItem(sender as UIBarButtonItem, autodismissAtTime: 2)
        } else {
            popTip.presentAnimatedPointingAtView(sender as UIView, inView: self.view, autodismissAtTime: 2)
        }
    }
}

