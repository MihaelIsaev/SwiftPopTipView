//
//  ViewController.swift
//  SwiftPopTipView
//
//  Created by Mihael Isaev on 18.12.14.
//  Copyright (c) 2014 Mihael Isaev inc. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    var roundRectButtonPopTipView: SwiftPopTipView?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setToolbarHidden(false, animated: false)
        let navBarLeftButtonPopTipView = SwiftPopTipView(message: "A message")
        navBarLeftButtonPopTipView.presentPointingAtBarButtonItem(navigationItem.leftBarButtonItem!, animated: true)
        navBarLeftButtonPopTipView.dismissAnimated(true)
    }
    
    @IBAction func showPopTip(_ sender: AnyObject) {
        let popTip = SwiftPopTipView(title: "Hello!", message: "This is the test pop tip view!!!")
        popTip.popColor = UIColor(red: 63/255, green: 162/255, blue: 232/255, alpha: 1)
        popTip.titleColor = UIColor.white
        popTip.textColor = UIColor.white
        if type(of: sender) === UIBarButtonItem.self {
            popTip.presentAnimatedPointingAtBarButtonItem(sender as! UIBarButtonItem, autodismissAtTime: 2)
        } else {
            popTip.presentAnimatedPointingAtView(sender as! UIView, inView: view, autodismissAtTime: 2)
        }
    }
}

